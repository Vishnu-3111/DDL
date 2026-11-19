!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for PostgreSQL database only
*/

var ssproperties = new Map();

function initialize()
{
	#sparx_initialize#
}
 
function main()
{
	try
	{
		initialize();
		
		var ddl_Element as EA.Element;
		var fk_connector as EA.Connector;
		var reference_table as EA.Element;
		var columns as EA.Attribute;	
		var constraints as EA.Method;
		var constraints_value as EA.Parameter;	
		
		var source_commands; // Source content will be added into the Export DDL File
		var source_Filepath; // Export DDl file path fromt the ssproperties object
		var ddl_FilePath;
		
		var fileSystemObj = new COMObject("Scripting.FileSystemObject");
		
		var genOutputType = ssproperties.get('GenerateOutput');
		if(genOutputType=="0")
		{
			ddl_FilePath =  ssproperties.get('Filename');
			source_Filepath = fileSystemObj.OpenTextFile(ddl_FilePath, 2, true);
		}
		else
		{
			ddl_FilePath =  ssproperties.get('FilePath');
		}
		
		var i = 0;
		var guid = ssproperties.get('Object' + i); // To get elements guid from the Generate ddl window
		while (guid != undefined)
		{	
			ddl_Element = Repository.GetElementByGuid(guid); // Selected elements from Generate ddl file window
			if(genOutputType == "1")
				source_Filepath = fileSystemObj.OpenTextFile(ddl_FilePath + ddl_Element.Name + ".sql", 2, true);
			elemList(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table);		
			if(genOutputType == "1")
				source_Filepath.Close();
			i++;
			guid = ssproperties.get('Object' + i);
		}		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
}

function elemList(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table)
{	
	var index = "";
	var trigger = "";
	
	if(ddl_Element.FQStereotype == "PostgreSQL::table") 
	{
		var table_commands = getTableElements(ddl_Element,columns,constraints,constraints_value,fk_connector,reference_table); // method for get table elements and its properties	
		source_commands = table_commands[0];
		index = table_commands[1];
		trigger = table_commands[2];
	}
	else if(ddl_Element.FQStereotype == "PostgreSQL::view") 
		source_commands = getViewElements(ddl_Element) // method for get view elements and its properties	
	else if(ddl_Element.FQStereotype == "PostgreSQL::sequence")
		source_commands = getSequenceElements(ddl_Element) // method for get Sequence elements and its properties	
	else if(ddl_Element.FQStereotype == "PostgreSQL::function")
		source_commands = getfunctionElements(ddl_Element) // method for get Function elements and its properties	
	else if(ddl_Element.FQStereotype == "PostgreSQL::procedure")
		source_commands = getProcedureElements(ddl_Element) // method for get Procedure elements and its properties		
	
	if(source_commands != "")
		source_commands += ";";	
	
	if(index != "" )
		source_commands += "\n\n"+index;	
	
	if(trigger != "" )
		source_commands += "\n\n"+trigger;
	
	source_Filepath.WriteLine(source_commands + "\n");
}

function getTableElements(ddl_Element,columns,constraints,constraints_value,fk_connector,reference_table)
{
	var source_commands = "";
	var index = "";
	var trigger = "";
	
	try
	{
		source_commands += "Create ";
		
		var scope_specification as EA.TaggedValue;
		scope_specification = ddl_Element.TaggedValues.GetByName("Scope Specification");
		
		if(scope_specification != null && scope_specification.Value != "" && scope_specification.Value != "<none>")
			source_commands += scope_specification.Value + " ";
		
		var table_type as EA.TaggedValue;
		table_type = ddl_Element.TaggedValues.GetByName("Table Type");
		
		if(table_type != null && table_type.Value != "<none>" && table_type.Value != "" )
			source_commands += table_type.Value + " ";
		
		source_commands += "Table ";
		
		var not_exists as EA.TaggedValue;
		not_exists = ddl_Element.TaggedValues.GetByName("Not Exists");
		
		if(not_exists != null && not_exists.Value == "True")
			source_commands += "If Not Exists " ;
		
		var databaseAndSchema as EA.TaggedValue;
		databaseAndSchema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(databaseAndSchema != null && databaseAndSchema.Value != "")
		{
			if(databaseAndSchema.Value.endsWith("."))
				source_commands += databaseAndSchema.Value;
			else
				source_commands += "\""+databaseAndSchema.Value+ "\".";
		}
		
		source_commands += "\""+ddl_Element.Name + "\"\n";
		
		var composite_type as EA.TaggedValue;
		composite_type = ddl_Element.TaggedValues.GetByName("Composite Type");
		
		if(composite_type != null && composite_type.Value != "")
			source_commands += "Of "+composite_type.Value + "\n";

		var subpartition as EA.TaggedValue;
		subpartition = ddl_Element.TaggedValues.GetByName("Subpartition");
		
		if(subpartition != null && subpartition.Value != "")
			source_commands += "Partition Of "+subpartition.Value+"\n" ;
		
		if(ddl_Element.Attributes.Count != 0 || ddl_Element.Methods.Count != 0)
			source_commands += "("  + "\n" ;
		
		source_commands += getTableColumns(ddl_Element,columns); //method for get table columns and its propeties		

		var table_constraint = getTableConstraints(ddl_Element,constraints,constraints_value,fk_connector,reference_table); //method for get table constraints and its properties
		source_commands += table_constraint[0];
		index += table_constraint[1];
		trigger += table_constraint[2];		
		
		
		if(ddl_Element.Attributes.Count != 0 ||  ddl_Element.Methods.Count != 0)
			source_commands +=  "\n)\n"   ;	
		
		source_commands += getTableConnectors(ddl_Element); //method for get relationship between table elements

		source_commands += getTableProperties(ddl_Element) // method for get additional properties for table elements
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [source_commands,index,trigger];
}

function getTableColumns(ddl_Element,columns)
{
	var source_commands = "";
	
	try
	{
		for(var j=0 ; j<ddl_Element.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = ddl_Element.Attributes.GetAt(j);
			source_commands += "\""+columns.Name + "\" " + columns.Type+" ";
			
			if(columns.Length != 0 || columns.Precision != 0)
			{
				if(columns.Length != 0)
					source_commands += "("+columns.Length;
				else if(columns.Precision != 0)
					source_commands += "("+columns.Precision;
				
				if(columns.Scale != 0)
					source_commands += ","+columns.Scale;
				
				source_commands +=") ";
			}		
			
			var with_option as EA.TaggedValue;
			with_option = columns.TaggedValues.GetByName("With Option");
			
			if(with_option != null && with_option.Value == "True")
				source_commands += "With Options ";
			
			var config_params as EA.TaggedValue;
			config_params = columns.TaggedValues.GetByName("Configuration");
			
			if(config_params != null && config_params.Notes != "")
				source_commands += "Options ( " +config_params.Notes+ " ) " ;  
			
			var storage_mode as EA.TaggedValue;
			storage_mode = columns.TaggedValues.GetByName("Storage Mode");
			
			if(storage_mode != null && storage_mode.Value != "" && storage_mode.Value != "<none>")
				source_commands += "Storage "+storage_mode.Value+" ";
			
			var compression as EA.TaggedValue;
			compression = columns.TaggedValues.GetByName("Compression");
			
			if(compression != null && compression.Value != "")
				source_commands += "Compression " + compression.Value +" ";
			
			var collate as EA.TaggedValue;
			collate = columns.TaggedValues.GetByName("Collate");
			
			if(collate != null && collate.Value != "")
				source_commands += "Collate "+collate.Value+" ";
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if (NotNull)
				source_commands += "Not Null ";		
			
			var default_expr = columns.Default;;
			
			if(default_expr != "")
				source_commands += "Default "+default_expr+" ";
			
			var generation_exprs as EA.TaggedValue;
			generation_exprs = columns.TaggedValues.GetByName("Generation Expression");
			
			if(generation_exprs != null && generation_exprs.Notes != "")
				source_commands += "Generated Always As ( "+generation_exprs.Notes+" ) Stored \n" ;
			
			var id_generation as EA.TaggedValue;
			id_generation = columns.TaggedValues.GetByName("Identity Generation");
			
			if(id_generation != null && id_generation.Value != "" && id_generation.Value != "<none>")
			{
				source_commands += "Generated "+id_generation.Value+" As Identity ";
				
				var seq_options as EA.TaggedValue;
				seq_options = columns.TaggedValues.GetByName("Sequence Options");
				
				if(seq_options != null && seq_options.Value != "")
					source_commands += "( "+seq_options.Value+" )\n";
			}
			
			if(j != ddl_Element.Attributes.Count - 1)
				source_commands += ","+ "\n";				
		}	
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;	
}

function getTableConstraints(ddl_Element,constraints,constraints_value,fk_connector,reference_table)
{
	var source_commands = "";
	var index = "";
	var trigger = "";
	
	try
	{		
		for(var k=0 ; k<ddl_Element.Methods.Count ; k++ )// To get the column constraints from the given table element
		{			
			constraints = ddl_Element.Methods.GetAt(k);
			
			var trg_event_value = "";
			var trg_constr = "";
			
			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "index" || constraints.Stereotype == "check" || constraints.Stereotype == "trigger")
			{
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					if(ddl_Element.Attributes.Count != 0 || K != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")						
						source_commands += "primary key (" ; 	
					else
						source_commands +=  "Constraint \""+constraints.Name+"\" primary key (" ; 
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					if(ddl_Element.Attributes.Count != 0 || K != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						source_commands += "foreign key (";
					else 
						source_commands +=  "Constraint \""+constraints.Name+"\" foreign key (" ; 
				}
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					if(ddl_Element.Attributes.Count != 0 || k != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")						
						source_commands += "unique (";
					else
						source_commands +=  "Constraint \""+constraints.Name+"\" unique (" ; 
				}
				else if(constraints.Stereotype == "check") // if the constraints was check
				{
					if(ddl_Element.Attributes.Count != 0 || k != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						source_commands += "Check (";
					else
						source_commands +=  "Constraint \""+constraints.Name+"\" Check (";
					
					if(constraints.Code != "")
						source_commands += constraints.Code ;
				}
				else if(constraints.Stereotype == "index")
				{
					index += "Create ";
					
					var is_unique as EA.TaggedValue;
					is_unique = constraints.TaggedValues.GetByName("Unique");
					
					if(is_unique != null)
					{
						if(is_unique.Value == "1" || is_unique.Value == "TRUE")
							index += "Unique ";
					}
					
					index += "Index ";
					
					var not_exists as EA.TaggedValue;
					not_exists = constraints.TaggedValues.GetByName("Not Exists");
					
					if(not_exists != null && not_exists.Value == "True")
						index += "If Not Exists ";
					
					index +="\"" +constraints.Name + "\" On " ;
					
					var targetTableSchema as EA.TaggedValue;
					targetTableSchema = constraints.TaggedValues.GetByName("Target Table schema");
						
					if(targetTableSchema != null && targetTableSchema.Value != "")
					{
						if(targetTableSchema.Value.endsWith("."))
							index += targetTableSchema.Value;
						else
							index += "\""+targetTableSchema.Value+ "\".";
					}
			
					
					index +="\""+ddl_Element.Name+ "\"\n" ;
					
					var idx_method as EA.TaggedValue;
					idx_method = constraints.TaggedValues.GetByName("Index Method");
					
					if(idx_method != null && idx_method.Value != "")
						index += "Using "+idx_method.Value+" \n " ;
					
					if(constraints.Parameters.Count != 0)
						index += "( "
					
				}		
				else if(constraints.Stereotype == "trigger")
				{
					trigger += "Create ";
					
					var is_replace as EA.TaggedValue;
					is_replace = constraints.TaggedValues.GetByName("Is Replace");
					
					if(is_replace != null && is_replace.Value == "True")
						trigger += "Or Replace ";
					
					var trigger_type as EA.TaggedValue;
						trigger_type = constraints.TaggedValues.GetByName("Trigger type");
						
						if(trigger_type != null && trigger_type.Value != "<none>" && trigger_type.Value != "")
						{
							trigger += trigger_type.Value + " "; 
					
							if(trigger_type.Value == "Event")
								trigger += "Event Trigger \"" + constraints.Name + "\"\n" ;
							
							else if(trigger_type.Value == "Constraint")
								trigger += "Constraint Trigger \"" + constraints.Name + "\"\n" ;
							
						}
						else
								trigger += "Trigger \"" + constraints.Name + "\"\n"  ;
					
					var trg_time as EA.TaggedValue;
					trg_time = constraints.TaggedValues.GetByName("TRG_TIME");
					
					if(trg_time != null && trg_time.Value != "")
						trigger += trg_time.Value + "\n";
					
					var trg_event as EA.TaggedValue;
					trg_event  = constraints.TaggedValues.GetByName("TRG_EVENT");
					
					if(trg_event != null && trg_event.Value != "")
						trg_event_value +=  trg_event.Value +"\n";	
				}
				
				
				var constraint_params = getConstraintsParameter(ddl_Element,constraints,constraints_value,trg_constr,trg_event_value); //method for get table constraints parameter
				source_commands += constraint_params[0];
				index += constraint_params[1];
				trigger += constraint_params[2];				
						
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "PostgreSQL::FK" connector
					source_commands += getForeignRefTable(ddl_Element,fk_connector,reference_table,constraints_value,constraints); // method for get reference table definition for Foreign key constraint
				
			}
		}
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [source_commands,index,trigger];
}

function getConstraintsParameter(ddl_Element,constraints,constraints_value,trg_constr,trg_event_value)
{
	var source_commands = "";
	var index = "";
	var trigger = "";
	
	try
	{
		for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
		{
			constraints_value = constraints.Parameters.GetAt(l);
			
			if(l>0)
			{
				if(constraints.Stereotype == "index" )
					index += ",";
				else if(constraints.Stereotype == "trigger")
					trg_constr += ",";						
				else
					source_commands += ","; 
			} 	
			
			if(constraints.Stereotype == "index" )
				index += constraints_value.Name;
			else if(constraints.Stereotype == "trigger")
					trg_constr += "\""+constraints_value.Name+"\"" ;
			else		
				source_commands+= "\""+constraints_value.Name+"\"";	
		}
		
		if(constraints.Stereotype == "index" )
		{
			if(constraints.Parameters.Count != 0)		
				index += " ) \n";
			
			var include_clause as EA.TaggedValue;
			include_clause = constraints.TaggedValues.GetByName("Include Clause");
			
			if(include_clause != null && include_clause.Notes != "")
				index += "Include ( " +include_clause.Notes+ " )\n" ;
			
			var null_distinct as EA.TaggedValue;
			null_distinct = constraints.TaggedValues.GetByName("Null Distinct");
			
			if(null_distinct != null)
			{
				if(null_distinct.Value == "Yes")
					index += "Nulls not Distinct \n";
				else if (null_distinct.Value == "No" )
					index += "Null Distinct \n";
			}
			
			var storage_params as EA.TaggedValue;
			storage_params = constraints.TaggedValues.GetByName("Storage Parameters");
			
			if(storage_params != null && storage_params.Notes != "" )
				index += "With ( " +storage_params.Notes+ " )\n";
			
			var table_space as EA.TaggedValue;
			table_space = constraints.TaggedValues.GetByName("TableSpace");
			
			if(table_space != null && table_space.Value != "")
				index += "TableSpace "+table_space.Value+"\n" ;
			
			var where_condition as EA.TaggedValue;
			where_condition = constraints.TaggedValues.GetByName("Where Condition");
			
			if(where_condition != null && where_condition.Notes != "")
				index += where_condition.Notes + "\n";
			
			index += "; \n\n";
		}
		else if(constraints.Stereotype == "trigger")
		{
			if(trg_event_value != "")
			{
				if(trg_event_value.includes("Update") && trg_constr !="") 
					trigger += trg_event_value.replace("Update", "Update Of " + trg_constr);							
				else
					trigger += trg_event_value;						
			}
			
			trigger += " On ";
			
			var targetTableSchema as EA.TaggedValue;
				targetTableSchema = constraints.TaggedValues.GetByName("Target Table schema");
					
			if(targetTableSchema != null && targetTableSchema.Value != "")
			{
				if(targetTableSchema.Value.endsWith("."))
					trigger += targetTableSchema.Value;
				else
					trigger += "\""+targetTableSchema.Value+ "\".";
			}
			
			trigger += "\""+ddl_Element.Name+ "\"\n";
			
			var trg_reference_table as EA.TaggedValue;
			trg_reference_table = constraints.TaggedValues.GetByName("Reference Table");
			
			if(trg_reference_table != null && trg_reference_table.Value != "")
				trigger += "From " +trg_reference_table.Value+ "\n";
			
			var constraint_deferral as EA.TaggedValue;
			constraint_deferral = constraints.TaggedValues.GetByName("Constraint Deferral");
			
			if(constraint_deferral != null && constraint_deferral.Value != "")
				trigger += constraint_deferral.Value + "\n";
			
			var transition_relation as EA.TaggedValue;
			transition_relation = constraints.TaggedValues.GetByName("Transition Relation");
			
			if(transition_relation != null && transition_relation.Notes != "" )
				trigger += "Referencing "+transition_relation.Notes+"\n";
			
			var for_each as EA.TaggedValue;
			for_each = constraints.TaggedValues.GetByName("For Each");
			
			if(for_each != null && for_each.Value != "<none>" && for_each.Value != "")
				trigger += "For Each "+for_each.Value+"\n" ;
			
			var is_event as EA.TaggedValue;
					is_event = constraints.TaggedValues.GetByName("Is Event Trigger");
					if(constraints.Code != "")
					{
						if(is_event != null && is_event.Value == "True")
						trigger += "When " +constraints.Code+" \n";
						else
						trigger += "When ( " +constraints.Code+" )\n";
					}
			
			var execute as EA.TaggedValue;
			execute = constraints.TaggedValues.GetByName("Execute");
			
			if(execute != null && execute.Notes != "")
				trigger += "Execute "+execute.Notes+"\n";						
			
			trigger += "; \n\n";
		}
		else		
			source_commands += ") ";	
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [source_commands,index,trigger] ;
}

function getForeignRefTable(ddl_Element,fk_connector,reference_table,constraints_value,constraints)
{
	var source_commands = "";
	
	try
	{
		for(var f=0 ; f<ddl_Element.Connectors.Count ; f++)
		{
			fk_connector = ddl_Element.Connectors.GetAt(f);

			if(fk_connector.FQStereotype == "PostgreSQL::FK" && fk_connector.ClientEnd.Role == constraints.Name)
			{
				var col_ref as EA.Method;
				
				reference_table = Repository.GetElementByID(fk_connector.SupplierID);
				
				source_commands += "References ";
				
				var targetTableSchema as EA.TaggedValue;
				targetTableSchema = constraints.TaggedValues.GetByName("Target Table schema");
					
					if(targetTableSchema != null && targetTableSchema.Value != "")
					{
						if(targetTableSchema.Value.endsWith("."))
							source_commands += targetTableSchema.Value;
						else
							source_commands += "\""+targetTableSchema.Value+ "\".";
					}

				source_commands +="\""+reference_table.Name+"\" ";
				
				var destRole = fk_connector.SupplierEnd.Role;

				var is_valid_constraint = false;

				for(var c=0 ; c<reference_table.Methods.Count ; c++)
				{
					col_ref = reference_table.Methods.GetAt(c);

					if(col_ref.Name == destRole)
					{
						is_valid_constraint = true;
						break;
					}
				}

				if(is_valid_constraint)
				{
					var ref_column_names = "";
					var constraints_value as EA.Parameter;	
					
					for(r=0; r<col_ref.Parameters.Count ; r++)
					{
						constraints_value = col_ref.Parameters.GetAt(r);							
						
						if(r>0)
							ref_column_names += ",";		
						
						ref_column_names += "\""+constraints_value.Name+"\"";
					}

					source_commands += "("+ref_column_names+") ";
				}
			}	
		}
		
		var on_update as EA.TaggedValue;
		on_update = constraints.TaggedValues.GetByName("Update");
		
		if(on_update != null && on_update.Value != "")
			source_commands += "On Update "+on_update.Value+" ";
		
		var on_delete as EA.TaggedValue;
		on_delete = constraints.TaggedValues.GetByName("Delete");
		
		if(on_delete != null && on_delete.Value != "")
			source_commands += "On Delete " +on_delete.Value+" ";		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	
	return source_commands;	
}

function getTableConnectors(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		var table_con as EA.Connector;
		var connected_table as EA.Element;
		
		
		for(var l=0 ; l<ddl_Element.Connectors.Count; l++)  // To include the Like table command from the Connectors list
		{
			table_con = ddl_Element.Connectors.GetAt(l);
			
			if(ddl_Element.ElementID == table_con.ClientID)
			{
				connected_table = Repository.GetElementByID(table_con.SupplierID);	
				
				if(table_con.FQStereotype == "PostgreSQL::like")	
				{
					source_commands += "( ";
					
					source_commands += "Like ";
					
					var target_table_schema as EA.TaggedValue;
					target_table_schema = table_con.TaggedValues.GetByName("Database and Schema");
					
					if(target_table_schema != null && target_table_schema.Value != "")
					{
						if(target_table_schema.Value.endsWith("."))
							source_commands += target_table_schema.Value;
						else
							source_commands += "\""+target_table_schema.Value+ "\".";
					}


					source_commands += "\""+ connected_table.Name + "\" ";
					
					var inclusion_property as EA.TaggedValue;
					inclusion_property = table_con.TaggedValues.GetByName("Inclusion Property"); 
					
					if(inclusion_property != null && inclusion_property.Value != "" && inclusion_property.Value != "<none>")
						source_commands += inclusion_property.Value+ " ";
					
					var property_spec as EA.TaggedValue;
					property_spec = table_con.TaggedValues.GetByName("Property Specification"); 
					
					if(property_spec != null && property_spec.Value != "" && property_spec.Value != "<none>")
						source_commands += property_spec.Value + " ";	

						source_commands += ") \n";
				}
			}	
		}		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;	
}

function getTableProperties(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		var partition_spec as EA.TaggedValue;
		partition_spec = ddl_Element.TaggedValues.GetByName("Partition Specification");		
		
		var boundary_spec as EA.TaggedValue;
		boundary_spec = ddl_Element.TaggedValues.GetByName("Boundary Specification");	
		
		if(partition_spec != null)
		{
			if(partition_spec.Value == "For Values")
			{
				source_commands += "For Values " ;	
				
				if(boundary_spec != null && boundary_spec.Notes != "")
					source_commands += boundary_spec.Notes +"\n" ;
			}
			else if(partition_spec.Value == "Default")
				source_commands += "Default \n"
		}
		
		var table_inheritance as EA.TaggedValue;
		table_inheritance = ddl_Element.TaggedValues.GetByName("Table Inheritance");	
		
		if(table_inheritance != null && table_inheritance.Notes != "")
			source_commands += "Inherits ( " +table_inheritance.Notes+ " )\n" ;
		
		var server_name as EA.TaggedValue;
		server_name = ddl_Element.TaggedValues.GetByName("Server Name");	
		
		if(server_name != null && server_name.Value != "")
			source_commands += "Server "+server_name.Value+"\n" ;
		
		var config_params as EA.TaggedValue;
		config_params =  ddl_Element.TaggedValues.GetByName("Configuration Parameters");	
		
		if(config_params != null && config_params.Notes != "")
			source_commands += "Options ( "+config_params.Notes+" )\n";
		
		var partition_method as EA.TaggedValue;
		partition_method = ddl_Element.TaggedValues.GetByName("Partition Method");	
		
		if(partition_method != null && partition_method.Value != "<none>" && partition_method.Value != "")
			source_commands += "Partition By " + partition_method.Value +" ";
		
		var partition_by as EA.TaggedValue;
		partition_by = ddl_Element.TaggedValues.GetByName("Partition By");	
		
		if(partition_by != null && partition_by.Notes != "")
			source_commands += "( "+partition_by.Notes+" )\n";
		
		var table_method as EA.TaggedValue;
		table_method = ddl_Element.TaggedValues.GetByName("Table Method");	
		
		if(table_method != null && table_method.Value != "")
			source_commands += "Using "+table_method.Value+"\n";

		var oid_configuration as EA.TaggedValue;
		oid_configuration = ddl_Element.TaggedValues.GetByName("OID Configuration");	
		
		var storage_parameters as EA.TaggedValue;
		storage_parameters = ddl_Element.TaggedValues.GetByName("Storage Parameters");	
		
		if(oid_configuration != null)
		{
			if(oid_configuration.Value == "With")
			{
				source_commands += "With " ;
				
				if(storage_parameters != null && storage_parameters.Notes != "")
					source_commands += "( "+storage_parameters.Notes+" )\n" ;
			}
			else if(oid_configuration.Value == "Without")
				source_commands += "Without \n";
		}
		
		var on_commit as EA.TaggedValue;
		on_commit = ddl_Element.TaggedValues.GetByName("On Commit");	
		
		if(on_commit != null && on_commit.Value != "" && on_commit.Value != "")
			source_commands += "On Commit "+on_commit.Value+" \n";
		
		var table_space as EA.TaggedValue;
		table_space = ddl_Element.TaggedValues.GetByName("TableSpace");	
		
		if(table_space != null && table_space.Value != "")
			source_commands += "TableSpace "+table_space.Value+"\n";
		
		var select_query as EA.TaggedValue;
		select_query = ddl_Element.TaggedValues.GetByName("Select Query");	
		
		if(select_query != null && select_query.Notes != "")
			source_commands += "As "+select_query.Notes+"\n";
		
		var data_load as EA.TaggedValue;
		data_load = ddl_Element.TaggedValues.GetByName("Data Load");

		if(data_load != null)
		{
			if(data_load.Value == "Yes")
				source_commands += "With No Data \n";
			else if(data_load.Value == "No")
				source_commands += "With Data \n";
		}		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;
}

function getViewElements(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		source_commands = "Create ";
		
		var is_replace as EA.TaggedValue;
		is_replace = ddl_Element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			source_commands += "Or Replace ";
		
		var temp_view as EA.TaggedValue;
		temp_view = ddl_Element.TaggedValues.GetByName("Temporary View");
		
		if(temp_view != null && temp_view.Value == "True")
			source_commands += "Temporary ";
		
		var is_recursive as EA.TaggedValue;
		is_recursive = ddl_Element.TaggedValues.GetByName("Recursive");
		
		if(is_recursive != null && is_recursive.Value == "True")
			source_commands += "Recursive ";
		
		var mat_view as EA.TaggedValue;
		mat_view = ddl_Element.TaggedValues.GetByName("Materialized View");
		
		if(mat_view != null && mat_view.Value == "True")
			source_commands += "Materialized " ;
		
		source_commands += "View ";
		
		var not_exists as EA.TaggedValue;
		not_exists = ddl_Element.TaggedValues.GetByName("Not Exists");
		
		if(not_exists != null && not_exists.Value == "True")
			source_commands += "If Not Exists ";
		
		var databaseAndSchema as EA.TaggedValue;
		databaseAndSchema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(databaseAndSchema != null && databaseAndSchema.Value != "")
		{
			if(databaseAndSchema.Value.endsWith("."))
				source_commands += databaseAndSchema.Value;
			else
				source_commands += "\""+databaseAndSchema.Value+ "\".";
		}
		
		source_commands += "\""+ddl_Element.Name + "\"\n";
		
		var recursive_with as EA.TaggedValue;
		recursive_with = ddl_Element.TaggedValues.GetByName("Recursive With");
		
		if(recursive_with != null && recursive_with.Value != "")
			source_commands += "As With Recursive " +recursive_with.Value+ " \n" ;
		
		var view_columns as EA.TaggedValue;
		view_columns = ddl_Element.TaggedValues.GetByName("View Columns");
		
		if(view_columns = null && view_columns.Notes != "")
			source_commands += "( " +view_columns.Notes+ " )\n";
		
		var view_method as EA.TaggedValue;
		view_method = ddl_Element.TaggedValues.GetByName("View Method");
		
		if(view_method != null && view_method.Value != "")
			source_commands += "Uisng " +view_method.Value+ "\n";
		
		var view_options as EA.TaggedValue;
		view_options = ddl_Element.TaggedValues.GetByName("View Options");
		
		if(view_options != null && view_options.Notes != "")
			source_commands += "With ( " +view_options.Notes+ " )\n";
		
		var table_space as EA.TaggedValue;
		table_space = ddl_Element.TaggedValues.GetByName("TableSpace");
		
		if(table_space != null && table_space.Value != "")
			source_commands += "TableSpace "+table_space.Value +"\n" ;
		
		var view_def as EA.TaggedValue;
		view_def = ddl_Element.TaggedValues.GetByName("viewdef");
		
		if(view_def != null && view_def.Notes != "")
			source_commands += "As "+view_def.Notes+" \n";
		
		var check_option as EA.TaggedValue;
		check_option = ddl_Element.TaggedValues.GetByName("Check Option");
		
		if(check_option != null && check_option.Value != "" && check_option.Value != "<none>")
			source_commands +=  "With " +check_option.Value+" Check Option \n";
		
		var data_load as EA.TaggedValue;
		data_load = ddl_Element.TaggedValues.GetByName("Data Load");
		
		if(data_load != null)
		{
			if(data_load.Value == "Yes")
				source_commands += "With Data \n";
			else if (data_load.Value == "No")
				source_commands += "With No Data \n";			
		}
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;	
}

function getSequenceElements(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		source_commands = "Create ";
		
		var seq_type as EA.TaggedValue;
		seq_type = ddl_Element.TaggedValues.GetByName("Sequence Type");
		
		if(seq_type != null && seq_type.Value != "<none>" && seq_type.Value != "")
			source_commands += seq_type.Value + " "; 
		
		source_commands += "Sequence ";
		
		var not_exists as EA.TaggedValue;
		not_exists = ddl_Element.TaggedValues.GetByName("Not Exists") ;
		
		if(not_exists != null && not_exists.Value == "True")
			source_commands += "If Not Exists ";
		
		var databaseAndSchema as EA.TaggedValue;
		databaseAndSchema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(databaseAndSchema != null && databaseAndSchema.Value != "")
		{
			if(databaseAndSchema.Value.endsWith("."))
				source_commands += databaseAndSchema.Value;
			else
				source_commands += "\""+databaseAndSchema.Value+ "\".";
		}
		
		source_commands +="\"" +ddl_Element.Name + "\"\n";
		
		var data_type as EA.TaggedValue;
		data_type = ddl_Element.TaggedValues.GetByName("Data Type Specification") ;
		
		if(data_type != null && data_type.Value != "")
			source_commands += "As "+ data_type.Value +"\n";
		
		var increment_by as EA.TaggedValue;
		increment_by = ddl_Element.TaggedValues.GetByName("Increment By") ;
		
		if(increment_by != null && increment_by.Value != "")
			source_commands += "Increment By "+ increment_by.Value +"\n";
		
		var minVal_spec as EA.TaggedValue;
		minVal_spec = ddl_Element.TaggedValues.GetByName("MinValue Specification") ;

		if(minVal_spec != null)
		{
			if(minVal_spec.Value == "Yes")
			{
				source_commands += "MinValue ";
				
				var minvalue as EA.TaggedValue;
				minvalue = ddl_Element.TaggedValues.GetByName("MinValue") ;
				
				if(minvalue != null && minvalue.Value != "")
					source_commands += minvalue.Value + " \n";
			}
			else if(minVal_spec.Value == "No")
				source_commands += "No MinValue \n";
		}
		
		var maxVal_spec as EA.TaggedValue;
		maxVal_spec = ddl_Element.TaggedValues.GetByName("MaxValue Specification") ;

		if(maxVal_spec != null)
		{
			if(maxVal_spec.Value == "Yes")
			{
				source_commands += "MaxValue ";
				
				var maxvalue as EA.TaggedValue;
				maxvalue = ddl_Element.TaggedValues.GetByName("MaxValue") ;
				
				if(maxvalue != null && maxvalue.Value != "")
					source_commands += maxvalue.Value + " \n";
			}
			else if(maxVal_spec.Value == "No")
				source_commands += "No MaxValue \n";
		}
		
		var start_with as EA.TaggedValue;
		start_with = ddl_Element.TaggedValues.GetByName("Start With") ;
		
		if(start_with != null && start_with.Value != "")
			source_commands += "Start With "+start_with.Value+" \n" ;
		
		var cache as EA.TaggedValue;
		cache = ddl_Element.TaggedValues.GetByName("Cache") ;
		
		if(cache != null && cache.Value != "")
			source_commands += "Cache "+cache.Value+" \n";
		
		var circular_sequence as EA.TaggedValue;
		circular_sequence = ddl_Element.TaggedValues.GetByName("Circular Sequence") ;
		
		if(circular_sequence != null )
		{
			if(circular_sequence.Value == "Yes")
				source_commands += "Cycle \n";
			else if(circular_sequence.Value == "No")
				source_commands += "No Cycle \n";
		}
		
		var owned_by as EA.TaggedValue;
		owned_by = ddl_Element.TaggedValues.GetByName("Owned By") ;
		
		if(owned_by != null && owned_by.Value != "")
			source_commands += "Owned By "+owned_by.Value+" \n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;		
}

function getfunctionElements(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		source_commands = "Create ";
		
		var is_replace as EA.TaggedValue;
		is_replace = ddl_Element.TaggedValues.GetByName("Is Replace") ;
		
		if(is_replace != null && is_replace.Value == "True")
			source_commands += "Or Replace ";
		
		source_commands += "Function ";
		
		var databaseAndSchema as EA.TaggedValue;
		databaseAndSchema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(databaseAndSchema != null && databaseAndSchema.Value != "")
		{
			if(databaseAndSchema.Value.endsWith("."))
				source_commands += databaseAndSchema.Value;
			else
				source_commands += "\""+databaseAndSchema.Value+ "\".";
		}
		
		
		source_commands+= "\""+ ddl_Element.Name + "\"\n";
		
		source_commands += "( " ;
		
		var func_arguments as EA.TaggedValue;
		func_arguments = ddl_Element.TaggedValues.GetByName("Arguments") ;
		
		if(func_arguments != null && func_arguments.Notes != "")
			source_commands += func_arguments.Notes ;
		
		source_commands += " ) \n" ;
		
		var return_table as EA.TaggedValue;
		return_table = ddl_Element.TaggedValues.GetByName("Return Tables") ;
		
		if(return_table != null && return_table.Notes != "")
			source_commands += "Returns Table ( "+return_table.Notes+" )\n";
		
		var return_type as EA.TaggedValue;
		return_type = ddl_Element.TaggedValues.GetByName("Return Type") ;
		
		if(return_type != null && return_type.Value != "")
			source_commands += "Returns "+return_type.Value+" \n";
		
		var language as EA.TaggedValue;
		language = ddl_Element.TaggedValues.GetByName("Language") ;
		
		if(language != null && language.Value != "")
			source_commands += "Language "+language.Value+" \n";
		
		var transform as EA.TaggedValue;
		transform = ddl_Element.TaggedValues.GetByName("Transform") ;
		
		if(transform != null && transform.Notes != "")
			source_commands += "Transform "+transform.Notes+" \n";	

		var window_function as EA.TaggedValue;
		window_function = ddl_Element.TaggedValues.GetByName("Window Function") ;
		
		if(window_function != null && window_function.Value == "True")
			source_commands += "Window \n"; 
		
		var volatility as EA.TaggedValue;
		volatility = ddl_Element.TaggedValues.GetByName("Volatility Category") ;
		
		if(volatility != null && volatility.Value != "")
			source_commands += volatility.Value + " \n"  ;
		
		var leak_proof as EA.TaggedValue;
		leak_proof = ddl_Element.TaggedValues.GetByName("Leakproof") ;
		
		if(leak_proof != null)
		{
			if(leak_proof.Value == "Yes")
				source_commands += "LeakProof \n";
			else if(leak_proof.Value == "No")
				source_commands += "Not LeakProof \n";			
		}
		
		var null_processing as EA.TaggedValue;
		null_processing = ddl_Element.TaggedValues.GetByName("Null Processing") ;
		
		if(null_processing != null)
		{
			if(null_processing.Value == "Called")
				source_commands += "Called On Null Input \n";
			else if(null_processing.Value == "Returns")
				source_commands += "Returns Null On Null Input \n" ;
			else if(null_processing.Value == "Strict")
				source_commands +=  "Strict \n";			
		}
		
		var security as EA.TaggedValue;
		security = ddl_Element.TaggedValues.GetByName("Security") ;
		
		if(security != null && security.Value != "")
			source_commands += "Security "+security.Value+"\n";
		
		var parallel as EA.TaggedValue;
		parallel = ddl_Element.TaggedValues.GetByName("Parallel") ;
		
		if(parallel != null && parallel.Value != "" && parallel.Value != "<none>")
			source_commands += "Parallel "+parallel.Value+" \n";
		
		var exe_cost as EA.TaggedValue;
		exe_cost = ddl_Element.TaggedValues.GetByName("Execution Cost") ;
		
		if(exe_cost != null && exe_cost.Value != "")
			source_commands += "Cost "+exe_cost.Value+" \n" ;
		
		var result_row as EA.TaggedValue;
		result_row = ddl_Element.TaggedValues.GetByName("Result Row") ;
		
		if(result_row != null && result_row.Value != "")
			source_commands += "Rows "+result_row.Value+" \n" ;
		
		var support_func as EA.TaggedValue;
		support_func = ddl_Element.TaggedValues.GetByName("Support Function") ;
		
		if(support_func != null && support_func.Value != "")
			source_commands += "Support "+support_func.Value+" \n";
		
		var configuration as EA.TaggedValue;
		configuration = ddl_Element.TaggedValues.GetByName("Configuration Parameters") ;
		
		if(configuration != null && configuration.Notes != "")
			source_commands += "Set "+configuration.Notes +" \n";
		
		var ex_linkage as EA.TaggedValue;
		ex_linkage = ddl_Element.TaggedValues.GetByName("External Linkage") ;
		
		if(ex_linkage != null && ex_linkage.Value != "")
			source_commands += "As "+ex_linkage.Value+" \n";
		
		var func_implementation as EA.TaggedValue;
		func_implementation = ddl_Element.TaggedValues.GetByName("Function Implementation") ;
		
		if(func_implementation != null && func_implementation.Value != "")
			source_commands += "As "+func_implementation.Value+" \n";
		
		var func_def as EA.TaggedValue;
		func_def = ddl_Element.TaggedValues.GetByName("funcdef") ;
		
		if(func_def != null && func_def.Notes != "") 
			source_commands += func_def.Notes + " \n";		
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;	
}

function getProcedureElements(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		source_commands = "Create ";
		
		var is_replace as EA.TaggedValue;
		is_replace = ddl_Element.TaggedValues.GetByName("Is Replace") ;
		
		if(is_replace != null && is_replace.Value == "True")
			source_commands += "Or Replace ";
		
		source_commands += "Procedure ";
		
		var databaseAndSchema as EA.TaggedValue;
		databaseAndSchema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(databaseAndSchema != null && databaseAndSchema.Value != "")
		{
			if(databaseAndSchema.Value.endsWith("."))
				source_commands += databaseAndSchema.Value;
			else
				source_commands += "\""+databaseAndSchema.Value+ "\".";
		}
		
		source_commands += "\""+ ddl_Element.Name + "\"\n" ;
		
		source_commands += "( ";
		
		var pro_args as EA.TaggedValue;
		pro_args = 	ddl_Element.TaggedValues.GetByName("Arguments") ;
		
		if(pro_args != null && pro_args.Notes != "")
			source_commands += pro_args.Notes ;
		
		source_commands += " ) \n";
		
		var language as EA.TaggedValue;
		language = ddl_Element.TaggedValues.GetByName("Language") ;
		
		if(language != null && language.Value != "")
			source_commands += "Language "+language.Value+" \n";
		
		var transform as EA.TaggedValue;
		transform = ddl_Element.TaggedValues.GetByName("Transform") ;
		
		if(transform != null && transform.Notes != "")
			source_commands += "Transform "+transform.Notes+" \n";	
		
		var security as EA.TaggedValue;
		security = ddl_Element.TaggedValues.GetByName("Security") ;
		
		if(security != null && security.Value != "")
			source_commands += "Security "+security.Value+"\n";
		
		var configuration as EA.TaggedValue;
		configuration = ddl_Element.TaggedValues.GetByName("Configuration Parameters") ;
		
		if(configuration != null && configuration.Notes != "")
			source_commands += "Set "+configuration.Notes +" \n";
		
		var ex_linkage as EA.TaggedValue;
		ex_linkage = ddl_Element.TaggedValues.GetByName("External Linkage") ;
		
		if(ex_linkage != null && ex_linkage.Value != "")
			source_commands += "As "+ex_linkage.Value+" \n";
		
		var proc_implementation as EA.TaggedValue;
		proc_implementation = ddl_Element.TaggedValues.GetByName("Procedure Implementation") ;
		
		if(proc_implementation != null && proc_implementation.Value != "")
			source_commands += "As "+proc_implementation.Value+" \n";
		
		var proc_def as EA.TaggedValue;
		proc_def = ddl_Element.TaggedValues.GetByName("procdef") ;
		
		if(proc_def != null && proc_def.Notes != "") 
			source_commands += proc_def.Notes + " \n";		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}

	return source_commands;	
}

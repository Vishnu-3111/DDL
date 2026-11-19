!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for MySQL database only
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
	
	if(ddl_Element.FQStereotype == "MySql::table") // if the given element was table 
	{		
		var table_commands = getTableElements(ddl_Element,columns,constraints,constraints_value,fk_connector,reference_table); // to get Table Elements and its properties
		source_commands = table_commands[0];
		index = table_commands[1];
		trigger = table_commands[2];		
	}
	else if(ddl_Element.FQStereotype == "MySql::view")
		source_commands = getViewElements(ddl_Element); // method for get the View Elements and its properties	
	else if(ddl_Element.FQStereotype == "MySql::function")
		source_commands = getFunctionElements(ddl_Element); // method for get the Function Elements and its properties	
	else if(ddl_Element.FQStereotype == "MySql::procedure")
		source_commands = getProcedureElements(ddl_Element);		
	
	if(source_commands != "")
		source_commands += ";";		
	
	if(index != "" )
		source_commands += "\n\n"+index;
	
	if(trigger != "")
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
		source_commands = "Create ";
		
		var temp_table as EA.TaggedValue;
		temp_table = ddl_Element.TaggedValues.GetByName("Is Temporary");
		
		if(temp_table != null && temp_table.Value == "True")
			source_commands += "Temporary ";
		
		source_commands += "Table ";
		
		var not_exists as EA.TaggedValue;
		not_exists =  ddl_Element.TaggedValues.GetByName("Not Exists");
		
		if(not_exists != null && not_exists.Value == "True")
			source_commands += "If Not Exists ";
		
		var schema_name as EA.TaggedValue;
		schema_name = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(schema_name != null && schema_name.Value != "")
		{
			if(schema_name.Value.endsWith("."))
				source_commands += schema_name.Value ;
			else
				source_commands += "`"+schema_name.Value +"`.";
		}
		source_commands += "`"+ddl_Element.Name +"`\n";
		
		if(ddl_Element.Attributes.Count != 0 || ddl_Element.Methods.Count != 0)
			source_commands += "("  + "\n" ;
		
		source_commands += getColumns(ddl_Element,columns); // method for getting table columns and its properties		
		
		var constraint_definition = getTableConstraint(ddl_Element,constraints,fk_connector,reference_table,constraints_value); // method for getting table constraints and its properties		
		source_commands += constraint_definition[0];
		index += constraint_definition[1];
		trigger += constraint_definition[2];			
				
		if(ddl_Element.Attributes.Count != 0 ||  ddl_Element.Methods.Count != 0)
			source_commands +=  "\n)\n"   ;	
		
		source_commands += getConnectors(ddl_Element); //method for get relationship of table elements 				
		
		var table_options as EA.TaggedValue;
		table_options = ddl_Element.TaggedValues.GetByName("Table Options");
		
		if(table_options != null && table_options.Notes != "")
			source_commands += table_options.Notes + "\n";
		
		var partition_by as EA.TaggedValue;
		partition_by = ddl_Element.TaggedValues.GetByName("Partition By");
		
		if(partition_by != null && partition_by.Notes != "")
			source_commands += table_options.Notes + "\n";
		
		var conflict_handling as EA.TaggedValue;
		conflict_handling = ddl_Element.TaggedValues.GetByName("Conflict Handling"); 
		
		if(conflict_handling != null && conflict_handling.Value != "" && conflict_handling.Value != "<none>" )
			source_commands += conflict_handling.Value + "\n";
		
		var select_query as EA.TaggedValue;
		select_query = ddl_Element.TaggedValues.GetByName("Select Query"); 
		
		if(select_query !=  null && select_query.Notes != "")
			source_commands += "As " +select_query.Notes + "\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	
	return [source_commands,index,trigger];	
}

function getColumns(ddl_Element,columns)
{
	var source_commands = "";
	
	try
	{
		for(var j=0 ; j<ddl_Element.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = ddl_Element.Attributes.GetAt(j);
			source_commands += "`"+columns.Name + "` " + columns.Type+" ";
			
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
			
			source_commands += getColumnProperties(columns); // method for using get additonal properties for Table columns					
			
			if(j != ddl_Element.Attributes.Count - 1)
				source_commands += ","+ "\n";				
		}		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands ;	
}

function getColumnProperties(columns)
{
	var source_commands = "";
	
	try
	{
		var Unsigned as EA.TaggedValue;
		Unsigned = columns.TaggedValues.GetByName("Unsigned");
		
		if(Unsigned != null && Unsigned.Value == "True")
			source_commands += "Unsigned ";
		
		var zerofill as EA.TaggedValue;
		zerofil = columns.TaggedValues.GetByName("Zerofill");
		
		if(zerofill != null && zerofil.Value == "True")
			source_commands += "Zerofill ";
		
		var listValues as EA.TaggedValue;
		listValues = columns.TaggedValues.GetByName("ListValues");
		if(listValues != null && listValues.Notes != "")
			source_commands += "( "+listValues.Notes +" ) ";
		
		var charaterSet as EA.TaggedValue;
		charaterSet = columns.TaggedValues.GetByName("CharaterSet");
		
		if(charaterSet != null && charaterSet.Value != "")
			source_commands += "charater Set "+ charaterSet.Value+" " ;
		
		var srid as EA.TaggedValue;
		srid = columns.TaggedValues.GetByName("SRID");
		
		if(srid != null && srid.Value != "")
			source_commands += "Srid "+ srid.Value+" " ;
		
		var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
		if (NotNull)
			source_commands += "Not Null ";
		
		var default_expr = columns.Default;
		
		if(default_expr != "")
			source_commands += "Default "+default_expr+" ";
		
		var visibility_sepc as EA.TaggedValue;
		visibility_sepc = columns.TaggedValues.GetByName("Visibility Specification");
		
		if(visibility_sepc != null && visibility_sepc.Value != "<none>" &&  visibility_sepc.Value != "")
			source_commands += visibility_sepc.Value + " ";
		
		var auto_increment as EA.TaggedValue;
		auto_increment = columns.TaggedValues.GetByName("Auto Increment");
		
		if(auto_increment != null && auto_increment.Value == "True")
			source_commands += "Auto_Increment ";
		
		var comment as EA.TaggedValue;
		comment = columns.TaggedValues.GetByName("Comment");
		
		if(comment != null && comment.Value != "")
			source_commands += "Comment "+comment.Value+" ";

		var collate as EA.TaggedValue;
		collate = columns.TaggedValues.GetByName("Collate");
		
		if(collate != null && collate.Value != "")
			source_commands += "Collate "+collate.Value+" ";
		
		var column_format as EA.TaggedValue;
		column_format = columns.TaggedValues.GetByName("Column Format");
		
		if(column_format != null && column_format.Value != "<none>" && column_format.Value != "")
			source_commands += column_format.Value + " ";
		
		var engine_attribute as EA.TaggedValue;
		engine_attribute = columns.TaggedValues.GetByName("Engine Attribute");
		
		if(engine_attribute != null && engine_attribute.Value != "")
			source_commands += "Engine_Attribute = "+engine_attribute.Value+" ";
		
		var secondary_engine as EA.TaggedValue;
		secondary_engine = columns.TaggedValues.GetByName("Engine Attribute");
		
		if(secondary_engine != null && secondary_engine.Value != "")
			source_commands += "Secondary_Engine_Attribute = "+secondary_engine.Value +" ";
		
		var storage as EA.TaggedValue;
		storage = columns.TaggedValues.GetByName("Storage");
		
		if(storage != null && storage.Value != "<none>" && storage.Value != "")
			source_commands += "Storage "+storage.Value +" " ;
		
		var generated_always as EA.TaggedValue;
		generated_always = columns.TaggedValues.GetByName("Generated Always");
		
		if(generated_always != null && generated_always.Value == "True")
			source_commands += "Generated Always ";
		
		var column_expr as EA.TaggedValue;
		column_expr = columns.TaggedValues.GetByName("Column Expression");
		
		if(column_expr != null && column_expr.Notes != "")
			source_commands += "As ( "+ column_expr.Notes +" ) " ;
				
		var computed_columns as EA.TaggedValue;
		computed_columns = columns.TaggedValues.GetByName("Computed Columns");
		
		if(computed_columns !=  null && computed_columns.Value != "<none>" && computed_columns.Value != "")
			source_commands += computed_columns.Value +" ";	
	
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}

	return source_commands;	
}

function getTableConstraint(ddl_Element,constraints,fk_connector,reference_table,constraints_value)
{
	var source_commands = "";
	var index = "";
	var trigger = "";
	
	try
	{
		for(var k=0 ; k<ddl_Element.Methods.Count ; k++ )// To get the column constraints from the given table element
		{			
			constraints = ddl_Element.Methods.GetAt(k);
			
			var is_table_index = false;
			
			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "index" || constraints.Stereotype == "check" || constraints.Stereotype == "trigger")
			{
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					if(ddl_Element.Attributes.Count != 0 || K != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")						
						source_commands += "primary key (" ; 	
					else
						source_commands +=  "Constraint `"+constraints.Name+"` primary key (" ; 
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					if(ddl_Element.Attributes.Count != 0 || K != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						source_commands += "foreign key (";
					else 
						source_commands +=  "Constraint `"+constraints.Name+"` foreign key (" ; 
				}
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					if(ddl_Element.Attributes.Count != 0 || k != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")						
						source_commands += "unique (";
					else
						source_commands +=  "Constraint `"+constraints.Name+"` unique (" ; 
				}
				else if(constraints.Stereotype == "check") // if the constraints was check
				{
					if(ddl_Element.Attributes.Count != 0 || k != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						source_commands += "Check (";
					else
						source_commands +=  "Constraint `"+constraints.Name+"` Check (";
					
					if(constraints.Code != "")
						source_commands += constraints.Code ;
				}
				else if(constraints.Stereotype == "index")
				{
					var table_index as EA.TaggedValue;
					table_index = constraints.TaggedValues.GetByName("Table Index");
					
					if(table_index != null && table_index.Value == "True")
						is_table_index = true;
					
					if(is_table_index)
					{
						if(ddl_Element.Attributes.Count != 0 || k != 0)
							source_commands+= "," +"\n";
						
						var idx_spec as EA.TaggedValue;
						idx_spec = constraints.TaggedValues.GetByName("Index Specification");
						
						if(idx_spec != null && idx_spec.Value != "<none>" && idx_spec.Value != "")
							source_commands += idx_spec.Value + " ";
						
						source_commands += "Index `"+constraints.Name+"` ( ";			
					}
					else
					{
						index += "Create ";
						
						var idx_spec as EA.TaggedValue;
						idx_spec = constraints.TaggedValues.GetByName("Index Specification");
						
						if(idx_spec != null && idx_spec.Value != "<none>" && idx_spec.Value != "")
							index += idx_spec.Value + " ";
						
						
						index += "Index ";
						var schema_name as EA.TaggedValue;
						schema_name = constraints.TaggedValues.GetByName("Database and Schema");
						
						if(schema_name != null && schema_name.Value != "")
						{
							if(schema_name.Value.endsWith("."))
								index += schema_name.Value ;
							else
								index += "`"+schema_name.Value +"`.";
						}
						index+= "`"+constraints.Name+"` On `"+ddl_Element.Name+"` (";
					}
				}		
				else if(constraints.Stereotype == "trigger")
				{
					trigger += getTriggerConstraint(constraints,ddl_Element); // method for getting Trigger constraint and its properties
				}
				
				var methods_parameter = getConstraintsParamters(constraints,constraints_value,is_table_index) ; // method for get Table constraint's paramter values
				source_commands += methods_parameter[0];
				index += methods_parameter[1];
				trigger += methods_parameter[2];
				
				source_commands += getForeignRefTable(constraints,ddl_Element,fk_connector,reference_table); // method for get foreign key's reference table and its properties				
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

function getTriggerConstraint(constraints,ddl_Element)
{
	var  trigger = "";
	
	try
	{
		trigger += "delimiter // \n";
		
		trigger += "Create ";
					
		var definer as EA.TaggedValue;
		definer = constraints.TaggedValues.GetByName("Definer");
		
		if(definer != null && definer.Value != "")
			trigger += "Definer = "+definer.Value+" ";  
		
		trigger += "Trigger ";
		
		var not_exists as EA.TaggedValue;
		not_exists =  constraints.TaggedValues.GetByName("Not Exists");

		if(not_exists != null && not_exists.Value == "True")
			trigger += "If Not Exists ";
		
		var schema_name as EA.TaggedValue;
			schema_name = constraints.TaggedValues.GetByName("Database and Schema");
			
			if(schema_name != null && schema_name.Value != "")
			{
				if(schema_name.Value.endsWith("."))
					trigger += schema_name.Value ;
				else
					trigger += "`"+schema_name.Value +"`.";
			}

		trigger += "`"+constraints.Name+ "` \n" ;
		
		var trg_time as EA.TaggedValue;
		trg_time = constraints.TaggedValues.GetByName("TRG_TIME");
		
		if(trg_time != null && trg_time.Value != "") 
			trigger += trg_time.Value + " \n";
		
		var trg_event as EA.TaggedValue;
		trg_event =  constraints.TaggedValues.GetByName("TRG_EVENT");
		
		if(trg_event != null && trg_event.Value != "")
			trigger += trg_event.Value + " \n";
		
		trigger += "On `"+ddl_Element.Name+"` \n";
		
		var each_row as EA.TaggedValue;
		each_row = constraints.TaggedValues.GetByName("Each Row");
		
		if(each_row != null && each_row.Value == "True")
			trigger += "For Each Row \n";
		
		var trg_order as EA.TaggedValue;
		trg_order = constraints.TaggedValues.GetByName("Trigger Order");
		
		if(trg_order != null && trg_order.Value != "")
			trigger += trg_order.Value+"\n";
		
		if(constraints.Code != "")
			trigger += constraints.Code+" //\n";	
			
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}

	return trigger;	
}

function getConstraintsParamters(constraints,constraints_value,is_table_index)
{
	var source_commands = "";
	var index = "";
	var trigger= "";
	
	try
	{
		for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
		{
			constraints_value = constraints.Parameters.GetAt(l);
			if(l>0)
			{
				if(constraints.Stereotype == "index" && !is_table_index)
					index += ",";
				else
					source_commands += ","; 
			} 	
			
			if(constraints.Stereotype == "index" && !is_table_index)
				index += "`"+constraints_value.Name+"`";
			else		
				source_commands+=  "`"+constraints_value.Name+"`";	
		}
		
		if(constraints.Stereotype == "index" && !is_table_index)
		{
			var param_expr as EA.TaggedValue;
			param_expr = constraints.TaggedValues.GetByName("Parameter Expression");
				
			if(param_expr != null && param_expr.Notes != "")
				index += "(" +param_expr.Notes + ")";
			
			index += ") \n";
			
			var block_size as EA.TaggedValue;
			block_size = constraints.TaggedValues.GetByName("Block Size");
			
			if(block_size != null && block_size.Value != "")
				index += "Key_Block_Size = "+block_size.Value+" \n";
			
			var index_type as EA.TaggedValue;
			index_type = constraints.TaggedValues.GetByName("Index Type");
			
			if(index_type != null && index_type.Value != "<none>" && index_type.Value != "")
				index += "Using "+index_type.Value+"\n ";
			
			var parser_name as EA.TaggedValue;
			parser_name = constraints.TaggedValues.GetByName("Parser Name");
			
			if(parser_name != null && parser_name.Value != "")
				index += "With Parser "+parser_name.Value+"\n ";
			
			var comment as EA.TaggedValue;
			comment = constraints.TaggedValues.GetByName("Comment");

			if(comment != null && comment.Value != "")
				index += "Comment "+comment.Value+"\n ";
			
			var visibility_spec as EA.TaggedValue;
			visibility_spec = constraints.TaggedValues.GetByName("Visibility Specification");
			
			if(visibility_spec != null && visibility_spec.Value != "" && visibility_spec.Value != "<none>")
				index += visibility_spec.Value+"\n ";
			
			var engine_attr as EA.TaggedValue;
			engine_attr = constraints.TaggedValues.GetByName("Engine Attribute");
			
			if(engine_attr != null && engine_attr.Value != "")
				index += "Engine_Attribute = "+engine_attr.Value+"\n ";
			
			var secondary_engine as EA.TaggedValue;
			secondary_engine = constraints.TaggedValues.GetByName("Secondary Engine");
			
			if(secondary_engine != null && secondary_engine.Value != "")
				index += "Secondary_Engine_Attribute = "+secondary_engine.Value+"\n ";
			
			var algorithm_option as EA.TaggedValue;
			algorithm_option = constraints.TaggedValues.GetByName("Algorithm Option");
			
			if(algorithm_option != null && algorithm_option.Value != "" && algorithm_option.Value != "<none>")
				index += "Algorithm = "+algorithm_option.Value+"\n ";
			
			var lock_option as EA.TaggedValue;
			lock_option = constraints.TaggedValues.GetByName("Lock Option");
			
			if(lock_option != null && lock_option.Value != "" )
				index += "Lock = "+lock_option.Value+"\n ";
			
			index += "; \n\n";
		}
		else if(constraints.Stereotype == "trigger")
			trigger += "; \ndelimiter ;\n\n";
		else		
		{	
			if(constraints.Stereotype == "index")
			{
				var param_expr as EA.TaggedValue;
				param_expr = constraints.TaggedValues.GetByName("Parameter Expression");
				
				if(param_expr != null && param_expr.Notes != "")
					source_commands += "(" +param_expr.Notes + ")";
			}
			
			source_commands += ") ";	
			
			if(constraints.Stereotype == "index")
			{
				var block_size as EA.TaggedValue;
				block_size = constraints.TaggedValues.GetByName("Block Size");
				
				if(block_size != null && block_size.Value != "")
					source_commands += "Key_Block_Size = "+block_size.Value+" ";
				
				var index_type as EA.TaggedValue;
				index_type = constraints.TaggedValues.GetByName("Index Type");
				
				if(index_type != null && index_type.Value != "<none>" && index_type.Value != "")
					source_commands += "Using "+index_type.Value+" ";
				
				var parser_name as EA.TaggedValue;
				parser_name = constraints.TaggedValues.GetByName("Parser Name");
				
				if(parser_name != null && parser_name.Value != "")
					source_commands += "With Parser "+parser_name.Value+" ";
				
				var comment as EA.TaggedValue;
				comment = constraints.TaggedValues.GetByName("Comment");
	
				if(comment != null && comment.Value != "")
					source_commands += "Comment "+comment.Value+" ";
				
				var visibility_spec as EA.TaggedValue;
				visibility_spec = constraints.TaggedValues.GetByName("Visibility Specification");
				
				if(visibility_spec != null && visibility_spec.Value != "" && visibility_spec.Value != "<none>")
					source_commands += visibility_spec.Value+" ";
				
				var engine_attr as EA.TaggedValue;
				engine_attr = constraints.TaggedValues.GetByName("Engine Attribute");
				
				if(engine_attr != null && engine_attr.Value != "")
					source_commands += "Engine_Attribute = "+engine_attr.Value+" ";
				
				var secondary_engine as EA.TaggedValue;
				secondary_engine = constraints.TaggedValues.GetByName("Secondary Engine");
				
				if(secondary_engine != null && secondary_engine.Value != "")
					source_commands += "Secondary_Engine_Attribute = "+secondary_engine.Value+" ";
			}
		}					
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [source_commands,index,trigger] ;	
}

function getForeignRefTable(constraints,ddl_Element,fk_connector,reference_table)
{
	var source_commands = "";
	
	try
	{
		if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "MySql::FK" connector
		{
			for(var f=0 ; f<ddl_Element.Connectors.Count ; f++)
			{
				fk_connector = ddl_Element.Connectors.GetAt(f);

				if(fk_connector.FQStereotype == "MySql::FK" && fk_connector.ClientEnd.Role == constraints.Name)
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
								source_commands += "`"+targetTableSchema.Value+"`.";
						}
					
					source_commands += "`"+reference_table.Name+"` ";
					
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
							
							ref_column_names += "`"+constraints_value.Name+"`";
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
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;
}

function getConnectors(ddl_Element)
{
	var source_commands ="";
	
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
				
				if(table_con.FQStereotype == "MySql::like")	
				{
					source_commands += "Like ";
					var schema_name as EA.TaggedValue;
					schema_name = table_con.TaggedValues.GetByName("Database and Schema");
					
					if(schema_name != null && schema_name.Value != "")
					{
						if(schema_name.Value.endsWith("."))
							source_commands += schema_name.Value;
						else
							source_commands += "`"+schema_name.Value+"`.";
					}
					source_commands +=  "`"+ connected_table.Name + "`\n";
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

function getViewElements(ddl_Element)
{
	var source_commands = "";
	
	try
	{		
		source_commands = "Create ";
		
		var is_replace as EA.TaggedValue;
		is_replace = ddl_Element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			source_commands +=  "Or Replace ";
		
		var algorithm_option as EA.TaggedValue;
		algorithm_option = ddl_Element.TaggedValues.GetByName("Algorithm Option");
					
		if(algorithm_option != null && algorithm_option.Value != "" && algorithm_option.Value != "<none>")
			source_commands += "Algorithm = "+algorithm_option.Value+" ";
		
		var definer as EA.TaggedValue;
		definer = ddl_Element.TaggedValues.GetByName("Definer");
					
		if(definer != null && definer.Value != "")
			source_commands += "Definer = "+definer.Value+" "; 
		
		var sql_security as EA.TaggedValue;
		sql_security = ddl_Element.TaggedValues.GetByName("Sql Security");
		
		if(sql_security != null && sql_security.Value != "<none>" && sql_security.Value != "")
			source_commands += "Sql Security "+sql_security.Value+" ";
		
		source_commands += "View ";
		
		var database_schema as EA.TaggedValue;
		database_schema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(database_schema != null && database_schema.Value != "")
		{
			if(database_schema.Value.endsWith("."))
			source_commands += database_schema.Value;
			else
			source_commands += "`"+database_schema.Value+"`.";
		}
		
		source_commands += "`"+ddl_Element.Name +"`\n ";

		var view_columns as EA.TaggedValue;
		view_columns = ddl_Element.TaggedValues.GetByName("View Columns");
		
		if(view_columns != null && view_columns.Notes != "")
			source_commands += "( "+view_columns.Notes+" )\n ";
		
		var view_def as EA.TaggedValue;
		view_def = ddl_Element.TaggedValues.GetByName("viewdef");
		
		if(view_def != null && view_def.Notes != "")
			source_commands += "As "+view_def.Notes+"\n";
		
		var chk_option as EA.TaggedValue;
		chk_option = ddl_Element.TaggedValues.GetByName("Check Option");
		
		if(chk_option != null)
		{
			if(chk_option.Value == "Default")
				source_commands += "With  Check Option \n";
			else if(chk_option.Value == "Cascaded")
				source_commands += "With Cascaded Check Option \n";
			else if(chk_option.Value == "Local")
				source_commands += "With Local Check Option \n";
		}		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;	
}

function getFunctionElements(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		var aggregate as EA.TaggedValue;
		aggregate = ddl_Element.TaggedValues.GetByName("Is Aggregate");
		
		if(aggregate != null && aggregate.Value != "True")
			source_commands+="delimiter // \n"
		
		source_commands += "Create ";
		
		var definer as EA.TaggedValue;
		definer = ddl_Element.TaggedValues.GetByName("Definer");
					
		if(definer != null && definer.Value != "")
			source_commands += "Definer = "+definer.Value+" "; 
		
		
					
		if(aggregate != null && aggregate.Value == "True")
			source_commands += "Aggregate "; 
		
		source_commands += "Function ";
		
		var not_exists as EA.TaggedValue;
		not_exists =  ddl_Element.TaggedValues.GetByName("Not Exists");
		
		if(not_exists != null && not_exists.Value == "True")
			source_commands += "If Not Exists ";
		
		var schema_name as EA.TaggedValue;
		schema_name = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(schema_name != null && schema_name.Value != "")
		{
			if(schema_name.Value.endsWith("."))
				source_commands += schema_name.Value;
			else
				source_commands += "`"+schema_name.Value+"`.";
		}
		
		source_commands += "`"+ddl_Element.Name +"`\n";
		
		var func_params as EA.TaggedValue;
		func_params = ddl_Element.TaggedValues.GetByName("Function Parameters");
		
		if(func_params != null && func_params.Notes != "")
			source_commands += "( "+func_params.Notes+" )\n";
		
		var returns_type as EA.TaggedValue;
		returns_type = ddl_Element.TaggedValues.GetByName("Returns");
		
		if(returns_type != null && returns_type.Value != "")
			source_commands += "Returns "+returns_type.Value+"\n";
		
		var comment as EA.TaggedValue;
		comment = ddl_Element.TaggedValues.GetByName("Comment");
		
		if(comment != null && comment.Value != "")
			source_commands += "Comment "+comment.Value+" ";
		
		var language as EA.TaggedValue;
		language = ddl_Element.TaggedValues.GetByName("Sql Language");
		
		if(language != null && language.Value == "True")
			source_commands += "Language Sql \n";
		
		var deterministic as EA.TaggedValue;
		deterministic = ddl_Element.TaggedValues.GetByName("Determinism Specifier");
		
		if(deterministic != null && deterministic.Value != "" && deterministic.Value != "<none>")
			source_commands += deterministic.Value +"\n";
		
		var func_char as EA.TaggedValue;
		func_char = ddl_Element.TaggedValues.GetByName("Function Characteristics");
		
		if(func_char != null && func_char.Value != "<none>" && func_char.Value != "")
			source_commands += func_char.Value + "\n";
		
		var sql_security as EA.TaggedValue;
		sql_security = ddl_Element.TaggedValues.GetByName("Sql Security");
		
		if(sql_security != null && sql_security.Value != "<none>" && sql_security.Value != "")
			source_commands +=  "Sql Security "+sql_security.Value+" ";
		
		var func_def as EA.TaggedValue;
		func_def = ddl_Element.TaggedValues.GetByName("funcdef");
		
		if(func_def != null && func_def.Notes != "")
			source_commands +=  func_def.Notes + "\n";
		
		var soname as EA.TaggedValue;
		soname = ddl_Element.TaggedValues.GetByName("Shared Library");
		
		if(soname != null && soname.Value != "")
			source_commands += "SoName "+soname.Value+"\n";
		
	if(aggregate != null && aggregate.Value != "True")
		source_commands+="// \n delimiter ;\n"
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
		source_commands+="delimiter // \n";
		
		source_commands += "Create ";
		
		var definer as EA.TaggedValue;
		definer = ddl_Element.TaggedValues.GetByName("Definer");
					
		if(definer != null && definer.Value != "")
			source_commands += "Definer = "+definer.Value+" "; 
		
		source_commands += "Procedure ";
		
		var not_exists as EA.TaggedValue;
		not_exists =  ddl_Element.TaggedValues.GetByName("Not Exists");
		
		if(not_exists != null && not_exists.Value == "True")
			source_commands += "If Not Exists ";
		
		var schema_name as EA.TaggedValue;
		schema_name = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(schema_name != null && schema_name.Value != "")
		{
			if(schema_name.Value.endsWith("."))
				source_commands += schema_name.Value;
			else
				source_commands += "`"+schema_name.Value+"`.";
		}
		
		source_commands += "`"+ddl_Element.Name +"`\n";
		
		var proc_params as EA.TaggedValue;
		proc_params = ddl_Element.TaggedValues.GetByName("Procedure Parameters");
		
		if(proc_params != null && proc_params.Notes != "")
			source_commands += "( "+proc_params.Notes+" )\n";
		
		var comment as EA.TaggedValue;
		comment = ddl_Element.TaggedValues.GetByName("Comment");
		
		if(comment != null && comment.Value != "")
			source_commands += "Comment "+comment.Value+" ";
		
		var language as EA.TaggedValue;
		language = ddl_Element.TaggedValues.GetByName("Sql Language");
		
		if(language != null && language.Value == "True")
			source_commands += "Language Sql \n";
		
		var deterministic as EA.TaggedValue;
		deterministic = ddl_Element.TaggedValues.GetByName("Determinism Specifier");
		
		if(deterministic != null && deterministic.Value != "" && deterministic.Value != "<none>")
			source_commands += deterministic.Value +"\n";
		
		var proc_char as EA.TaggedValue;
		proc_char = ddl_Element.TaggedValues.GetByName("Procedure Characteristics");
		
		if(proc_char != null && proc_char.Value != "<none>" && proc_char.Value != "")
			source_commands += proc_char.Value + "\n";
		
		var sql_security as EA.TaggedValue;
		sql_security = ddl_Element.TaggedValues.GetByName("Sql Security");
		
		if(sql_security != null && sql_security.Value != "<none>" && sql_security.Value != "")
			source_commands +=  "Sql Security "+sql_security.Value+" \n";
		
		var proc_def as EA.TaggedValue;
		proc_def = ddl_Element.TaggedValues.GetByName("procdef");
		
		if(proc_def != null && proc_def.Notes != "")
			source_commands +=  proc_def.Notes + "\n";		
		
		source_commands+="//\ndelimiter ; \n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	
	return source_commands;	
}




!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for Teradata database only
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
	if(ddl_Element.FQStereotype == "Teradata::table") // if the given element was table 
	{		
		var table_commands = getTableElements(ddl_Element,columns,constraints,constraints_value,fk_connector,reference_table); // method for get table elements and its properties
		
		source_commands = table_commands[0];
		index = table_commands[1];
		trigger = table_commands[2];
	}
	else if(ddl_Element.FQStereotype == "Teradata::view") // if the given element was view 
		source_commands = getViewElements(ddl_Element); 
	else if(ddl_Element.FQStereotype == "Teradata::function")
		source_commands = getfunctionElements(ddl_Element); 	
	else if(ddl_Element.FQStereotype == "Teradata::procedure")
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
		
		var duplication_mode as EA.TaggedValue;
		duplication_mode = ddl_Element.TaggedValues.GetByName("Duplication Mode");
		
		if(duplication_mode != null && duplication_mode.Value != "" && duplication_mode.Value != "<none>")
			source_commands += duplication_mode.Value+" ";
		
		var table_type as EA.TaggedValue;
		table_type = ddl_Element.TaggedValues.GetByName("Table Type");
		
		if(table_type != null && table_type.Value != "" && table_type.Value != "<none>")
			source_commands += table_type.Value+" " ;			
		
		var error_conn as EA.Connector;
	    var error_for as EA.Element;
		var error_table_name = "";		
		
		for(var l=0 ; l<ddl_Element.Connectors.Count; l++)  // To include the error table command from the Connectors list
		{
			error_conn = ddl_Element.Connectors.GetAt(l);
			
			var target_fqname as EA.TaggedValue;
			if(ddl_Element.ElementID == error_conn.ClientID)
			{
				error_for = Repository.GetElementByID(error_conn.SupplierID);	
				
				target_fqname = error_for.TaggedValues.GetByName("Schema and Database");
				
				if(error_conn.FQStereotype == "Teradata::error")	
				{
					if(target_fqname!=null &&target_fqname.Value!="")
					{
						source_commands += "Error ";
						if(target_fqname.Value.endsWith("."))
							error_table_name = target_fqname.Value+"\""+error_for.Name+"\"";
						else
							error_table_name = "\""+target_fqname.Value+"\"."+"\""+error_for.Name+"\"";
					}
				}
			}
			
		}
		
		source_commands += "Table ";
		
		var fq_tableName as EA.TaggedValue; 
		fq_tableName = ddl_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_tableName != null && fq_tableName.Value != "")
		{
			if(fq_tableName.Value.endsWith("."))
				source_commands += fq_tableName.Value;
			else
				source_commands += "\""+fq_tableName.Value+"\".";
		}
		
		source_commands += "\""+ddl_Element.Name +"\"\n";
		
		if(error_table_name != "")
		{
			source_commands += "For \""+error_table_name+"\"\n";
			
			var no_rls as EA.TaggedValue;
			no_rls = ddl_Element.TaggedValues.GetByName("No RLS");
			
			if(no_rls != null && no_rls.Value == "True")
				source_commands += "No RLS \n" ;
		}
		
		var is_queue as EA.TaggedValue;
		is_queue =  ddl_Element.TaggedValues.GetByName("Is Queue");		
		
		if(is_queue != null && is_queue.Value == "True")
			source_commands += ", Queue \n";
		
		var table_option as EA.TaggedValue;
		table_option = ddl_Element.TaggedValues.GetByName("Table Option");
		
		if(table_option != null && table_option.Notes != "")
			source_commands += ","+table_option.Notes+"\n";		
		
		if(ddl_Element.Attributes.Count != 0)
			source_commands += "("  + "\n" ;
		
		source_commands += getTableColumns(ddl_Element,columns); // method for get table columns and its properties

		var table_constraint = getTableConstraint(ddl_Element,constraints,constraints_value,fk_connector,reference_table); // method for get table constraints and its properties
		source_commands += table_constraint[0];
		index += table_constraint[1];
		trigger += table_constraint[2];		
		
		if(ddl_Element.Attributes.Count != 0)
			source_commands +=  "\n)\n"   ;	
		
		source_commands += getTableProperties(ddl_Element); // method for get table additional properties
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
			
			var interval_field_value as EA.TaggedValue;
			interval_field_value =  columns.TaggedValues.GetByName("interval Field list");
			
			if(interval_field_value != null && interval_field_value.Value != "")
				source_commands += interval_field_value.Value +" " ;
			
			var period_field_value as EA.TaggedValue;
			period_field_value =  columns.TaggedValues.GetByName("Period Field list");
			
			if(period_field_value != null && period_field_value.Value != "")
				source_commands += period_field_value.Value+" " ;	
			
			var inline_length as EA.TaggedValue;
			inline_length =  columns.TaggedValues.GetByName("inline length");
			
			if(inline_length != null && inline_length.Value != "")
				source_commands += "inline length " + inline_length.Value +" " ;
			
			var storage_format as EA.TaggedValue;
			storage_format =  columns.TaggedValues.GetByName("Storage Format");
			
			if(storage_format != null && storage_format.Value != "<none>" && storage_format.Value != "")
				source_commands += " Storage format " + storage_format.Value +" " ;
												
			var uppercase as EA.TaggedValue;
			uppercase =  columns.TaggedValues.GetByName("Uppercase");
			
			if(uppercase != null && uppercase.Value == "True")
				source_commands += "Uppercase " ;
			
			var case_sensitivity as EA.TaggedValue;
			case_sensitivity =  columns.TaggedValues.GetByName("Case Sensitivity");
			
			if(case_sensitivity != null ) 
			{
				if(case_sensitivity.Value == "Casespecific")
					source_commands += "Casespecific ";
				else if(case_sensitivity.Value == "Not Casespecific")
					source_commands += "Not Casespecific ";
			}
			
			var format as EA.TaggedValue;
			format = columns.TaggedValues.GetByName("Format");
			
			if(format != null && format.Value != "")
				source_commands += "Format "+format.Value+" ";
			
			var title as EA.TaggedValue;
			title = columns.TaggedValues.GetByName("Title");
			
			if(title != null && title.Value != "")
				source_commands += "Title "+title.Value+" ";
			
			var named as EA.TaggedValue;
			named = columns.TaggedValues.GetByName("Named");
			
			if(named != null && named.Value != "")
				source_commands += "Named "+ named.Value+" ";			
					
			if( columns.Default != "")				
				source_commands += "Default "+columns.Default+" " ;
			
			var with_default as EA.TaggedValue ;
			with_default = columns.TaggedValues.GetByName("With Default");
			
			if(with_default != null && with_default.Value == "True")
				source_commands += "With Default ";
			
			var char_set as EA.TaggedValue;
			char_set = columns.TaggedValues.GetByName("CharacterSet");
			
			if(char_set != null && char_set.Value != "")
				source_commands += "Character Set "+char_set.Value+" ";
			
			var snappy_compression as EA.TaggedValue;
			snappy_compression =  columns.TaggedValues.GetByName("snappy compress");
			
			if(snappy_compression != null && snappy_compression.Value != "")
				source_commands += snappy_compression.Value +" " ;
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if (NotNull)
				source_commands += "Not Null ";
			
			var auto_increment as EA.TaggedValue;
			auto_increment = columns.TaggedValues.GetByName("Auto Increment");
			
			if(auto_increment != null )
			{
				if(auto_increment.Value == "Not Auto Column")
					source_commands += "Not Auto Column ";
				else if(auto_increment.Value == "Auto Column")
					source_commands += "Auto Column ";
			}
			
			var compression_attribute as EA.TaggedValue;
			compression_attribute = columns.TaggedValues.GetByName("Compression Attribute");
			
			if(compression_attribute != null && compression_attribute.Notes != "")
				source_commands += compression_attribute.Notes + " ";		
					
				
			var id_column as EA.TaggedValue;
			id_column = columns.TaggedValues.GetByName("Identity Column");
			
			if(id_column != null && id_column.Notes != "")
				source_commands += id_column.Notes+" ";			
			
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

function getTableConstraint(ddl_Element,constraints,constraints_value,fk_connector,reference_table)
{
	var source_commands = "";
	var index = "";
	var trigger = "";
	
	try
	{
		for(var k=0 ; k<ddl_Element.Methods.Count ; k++ )// To get the column constraints from the given table element
		{
			constraints = ddl_Element.Methods.GetAt(k);
			
			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "index" || constraints.Stereotype == "trigger" )
			{
				var index_type as EA.TaggedValue;
				var trg_event as EA.TaggedValue;
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					source_commands+= "," +"\n";
					
					if(constraints.Name == "")						
						source_commands += "primary key (" ; 	
					else
						source_commands +=  "Constraint \""+constraints.Name+"\" primary key (" ; 					
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					source_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						source_commands += "foreign key (";
					else 
						source_commands +=  "Constraint \""+constraints.Name+"\" foreign key (" ; 
				}	
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					source_commands += "," +"\n";
					if(constraints.Name == "")						
						source_commands += "unique (";
					else
						source_commands +=  "Constraint \""+constraints.Name+"\" unique (" ; 
				}
				else if(constraints.Stereotype == "check") // if the constraints was check
				{
					source_commands += "," +"\n";
					
					if(constraints.Name == "")	
						source_commands += "Check (";
					else
						source_commands +=  "Constraint \""+constraints.Name+"\" Check (";
					
					if(constraints.Code != "")
						source_commands += constraints.Code ;
					
				}
				else if(constraints.Stereotype == "index") // if the constraints was index
				{
					index += "Create " ;	
					
					index_type = constraints.TaggedValues.GetByName("Index Type")
					
					if(index_type != null)
					{
						if(index_type.Value == "Join")
							index += "Join ";
						else if(index_type.Value == "Hash")
							index += "Hash ";						
					}
					
					var is_unique as EA.TaggedValue;
					is_unique = constraints.TaggedValues.GetByName("Unique");
					
					if(is_unique != null)
					{
						if(is_unique.Value == "1" || is_unique == "TRUE")
							index += "Unique ";
					}
					
					index += "Index ";
					
					var fq_index_name as EA.TaggedValue;
					fq_index_name = constraints.TaggedValues.GetByName("Schema and Database");
					
					if(fq_index_name != null && fq_index_name.Value != "")
					{
						if(fq_index_name.Value.endsWith("."))
							index += fq_index_name.Value;	
						else
							index += "\""+fq_index_name.Value+"\".";

					}
										
					index += "\""+constraints.Name+ "\"\n";
					
					if(index_type != null && index_type.Value == "Join" && constraints.Code != "")			
						index += "As "+constraints.Code+"\n";
					
					var table_index as EA.TaggedValue;
					table_index = constraints.TaggedValues.GetByName("Table Index");
					
					if(table_index != null && table_index.Notes != "")
						index += table_index.Notes+"\n";
					
					var all_columns as EA.TaggedValue;
					all_columns = constraints.TaggedValues.GetByName("All Columns");
					
					if(all_columns != null && all_columns.Value == "True")
						index += "All \n";
					
					if(index_type != null && index_type.Value != "Join" )
						index +="(";
					
				}
				else if(constraints.Stereotype == "trigger") // if the constraints was trigger
				{
					var trigger_type as EA.TaggedValue;
					trigger_type = constraints.TaggedValues.GetByName("Trigger Type");
					
					if(trigger_type != null && trigger_type.Value == "Replace")
						trigger += "Replace Trigger ";
					else
						trigger += "Create Trigger ";	
					
					var fq_trigger_name as EA.TaggedValue;
					fq_trigger_name = constraints.TaggedValues.GetByName("Schema and Database");
					
					if(fq_trigger_name != null && fq_trigger_name.Value !="")
					{
						if(fq_trigger_name.Value.endsWith("."))
							trigger += fq_trigger_name.Value ;
						else
							trigger += "\""+fq_trigger_name.Value + "\".";
					}
						
					trigger +=  "\""+constraints.Name+"\" " ;
					
					var trigger_status as EA.TaggedValue;
					trigger_status = constraints.TaggedValues.GetByName("Trigger Status");
					
					if(trigger_status != null)
					{
						if(trigger_status.Value == "Enabled")
							trigger += "Enabled ";
						else if(trigger_status.Value == "Disabled")
							trigger += "Disabled ";						
					}					
					
					var trg_time as EA.TaggedValue;
					trg_time = constraints.TaggedValues.GetByName("TRG_TIME");
					
					if(trg_time != null)
					{
						if(trg_time.Value == "Before")
							trigger += "Before ";
						else if(trg_time.Value == "After")
							trigger += "After ";
					}
					
					var temp_option as EA.TaggedValue;
					temp_option = constraints.TaggedValues.GetByName("Temporal Option");
					
					if(temp_option != null && temp_option.Value != "")
						trigger += temp_option.Value+" ";
					
					trg_event = constraints.TaggedValues.GetByName("TRG_EVENT");
					
					if(trg_event != null)
					{
						if(trg_event.Value == "Insert")
							trigger += "Insert ";
						else if(trg_event.Value == "Delete")
							trigger += "Delete ";
						else if(trg_event.Value == "Update")
							trigger += "Update ";						
					}
					
					if(constraints.Parameters.Count != 0)
						trigger += "Of ("
				}
				
				var constraint_params = getConstraintParameter(constraints,constraints_value,ddl_Element,index_type); // method for get Constraint parameters
				source_commands += constraint_params[0];
				index += constraint_params[1];
				trigger += constraint_params[2];				
				
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "Teradata::FK" connector
					source_commands += getForeignKeyRefTable(ddl_Element,fk_connector,reference_table,constraints);
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

function getConstraintParameter(constraints,constraints_value,ddl_Element,index_type)
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
				if(constraints.Stereotype == "index")
					index += ",";	
				else if(constraints.Stereotype == "trigger")
					trigger += ",";
				else
					source_commands += ','; 
			} 	
			
			if(constraints.Stereotype == "index")
				index += "\""+constraints_value.Name+"\"";
			else if(constraints.Stereotype == "trigger")
				trigger += "\""+constraints_value.Name+"\"";
			else
				source_commands+= "\""+constraints_value.Name+"\"";	
		}
		
		if(constraints.Stereotype == "index")
		{
			if(index_type != null && index_type.Value != "Join" )				
				index += ") \n";
			
			if(index_type != null && index_type.Value != "Hash" )	
			{
				var order_by as EA.TaggedValue;
				order_by = constraints.TaggedValues.GetByName("Order By");

				if(order_by != null && order_by.Notes != "")
					index += "Order By "+order_by.Notes+"\n";
			}	
			
			var with_load as EA.TaggedValue;
			with_load = constraints.TaggedValues.GetByName("With Load");

			if(with_load != null)
			{
				if(with_load.Value == "True")
					index += "With Load Identity \n" ;
				else if(with_load.Value == "False")
					index += "With No Load Identity \n";
			}
			
			if(index_type != null && index_type.Value != "Join" )			
				index += "On ";

			var is_tem as EA.TaggedValue;
			is_tem = constraints.TaggedValues.GetByName("Is Temporary");

			if(is_tem != null && is_tem.Value == "True")
				index += "Temporary ";
			
			var fq_tableName as EA.TaggedValue; 
				fq_tableName = ddl_Element.TaggedValues.GetByName("Schema and Database");
				
				if(fq_tableName != null && fq_tableName.Value != "")
				{
					if(fq_tableName.Value.endsWith("."))
						index += fq_tableName.Value;
					else
						index +="\""+ fq_tableName.Value+"\".";
				}
					
			if(index_type != null && index_type.Value != "Join" )			
				index += "\""+ddl_Element.Name+"\"\n";

			var table_option as EA.TaggedValue;
			table_option = constraints.TaggedValues.GetByName("Table Option");

			if(table_option != null && constraints.Notes != "")
				index += table_option.Notes+"\n";				
							
			var column_by as EA.TaggedValue;
			column_by = constraints.TaggedValues.GetByName("Column By");
			
			if(column_by != null && column_by.Notes != "")
				index += "By ("+column_by.Notes+")\n" ;
			
			if(index_type != null && index_type.Value == "Hash" )	
			{
				var order_by as EA.TaggedValue;
				order_by = constraints.TaggedValues.GetByName("Order By");

				if(order_by != null && order_by.Notes != "")
					index += "Order By "+order_by.Notes+"\n";
			}

			index += ";";
		}
		else if(constraints.Stereotype == "trigger")
		{
			if(constraints.Parameters.Count != 0)
				trigger += ")\n" ;
			
				trigger +="on " ;
			var fq_trigger_name as EA.TaggedValue;
				fq_trigger_name = ddl_Element.TaggedValues.GetByName("Schema and Database");
					
			if(fq_trigger_name != null && fq_trigger_name.Value !="")
			{
				if(fq_trigger_name.Value.endsWith("."))
				trigger += fq_trigger_name.Value ;
				else
				trigger += "\""+fq_trigger_name.Value + "\".";
			}
			
			trigger += "\""+ddl_Element.Name+"\"\n";
			
			var trg_order as EA.TaggedValue;
			trg_order = constraints.TaggedValues.GetByName("Trigger Order");
			
			if(trg_order != null && trg_order.Value != "")
				trigger += "Order "+trg_order.Value+"\n";
			
			var reference as EA.TaggedValue;
			reference = constraints.TaggedValues.GetByName("Reference");
			
			if(reference != null && reference.Value != "")
				trigger += "Referencing "+reference.Value+"\n";
			
			var for_each as EA.TaggedValue;
			for_each = constraints.TaggedValues.GetByName("For Each");
			
			if(for_each != null && for_each.Value != "")
				trigger += "For Each "+for_each.Value+"\n";
			
			var search_condition as EA.TaggedValue;
			search_condition = constraints.TaggedValues.GetByName("Search Condition");
			
			if(search_condition != null && search_condition.Notes != "")
				trigger += "When ("+search_condition.Notes+")\n";
			
			if(constraints.Code != "")
				trigger += constraints.Code+"\n";
			
			trigger += ";";
		}
		else
			source_commands += ") ";	
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [source_commands,index,trigger];		
}

function getForeignKeyRefTable(ddl_Element,fk_connector,reference_table,constraints)
{
	var source_commands = "";
	
	try
	{
		for(var f=0 ; f<ddl_Element.Connectors.Count ; f++)
		{
			fk_connector = ddl_Element.Connectors.GetAt(f);

			if(fk_connector.FQStereotype == "Teradata::FK" && fk_connector.ClientEnd.Role == constraints.Name)
			{
				var col_ref as EA.Method;
				
				reference_table = Repository.GetElementByID(fk_connector.SupplierID);

				source_commands += "References \""+reference_table.Name+"\" ";
				
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

					source_commands += "("+ref_column_names+")";
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
		var foreign_table_expression as EA.TaggedValue;
		foreign_table_expression = ddl_Element.TaggedValues.GetByName("Foreign Table Expression");
		
		if(foreign_table_expression != null && foreign_table_expression.Notes != "")
			source_commands += "Using ("+foreign_table_expression.Notes+" )\n";
		
		var table_index as EA.TaggedValue;
		table_index = ddl_Element.TaggedValues.GetByName("Table Index");
		
		if(table_index != null && table_index.Notes != "")
			source_commands += table_index.Notes+"\n";
		
		var as_clause as EA.TaggedValue;
		as_clause =  ddl_Element.TaggedValues.GetByName("As Clause");
		
		if(as_clause != null && as_clause.Notes != "")
			source_commands += as_clause.Notes+"\n";
		
		var table_preservation as EA.TaggedValue;
		table_preservation = ddl_Element.TaggedValues.GetByName("Table Preservation");
		
		if(table_preservation != null)
		{
			if(table_preservation.Value == "Delete")
				source_commands += "On Commit Delete Rows \n";
			else if(table_preservation.Value == "Preserve")
				source_commands +=  "On Commit Preserve Rows \n";
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
		var view_type as EA.TaggedValue;
		view_type = ddl_Element.TaggedValues.GetByName("View Type");
		
		if(view_type != null && view_type.Value == "Replace")
		{
			source_commands = "Replace " ;
		}
		else
			source_commands = "Create ";
		
		var is_recursive as EA.TaggedValue;
		is_recursive = ddl_Element.TaggedValues.GetByName("Is Recursive");
		
		if(is_recursive != null && is_recursive.Value == "True")
			source_commands += "Recursive ";
		
		source_commands += "View ";
		
		var fq_view_name as EA.TaggedValue;
		fq_view_name = ddl_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_view_name != null && fq_view_name.Value != "")
		{
			if(fq_view_name.Value.endsWith("."))
			source_commands += fq_view_name.Value;
			else
				source_commands += "\""+fq_view_name.Value+"\".";
		}
		source_commands += "\""+ddl_Element.Name+"\"\n";
		
		var view_columns as EA.TaggedValue;
		view_columns = ddl_Element.TaggedValues.GetByName("View Columns");
		
		if(view_columns != null && view_columns.Notes != "")
			source_commands += "("+view_columns.Notes+")\n";
		
		var view_specification as EA.TaggedValue;
		view_specification = ddl_Element.TaggedValues.GetByName("viewdef");
		
		if(view_specification != null && view_specification.Notes != "")
		{	var view_def="";
			view_def=view_specification.Notes.toLowerCase();
			if(!view_def.startsWith("with"))
				source_commands += "As ("+view_specification.Notes+")\n";	
			else
				source_commands += "As "+view_specification.Notes+"\n";	
		}
			
		
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
		var func_type as EA.TaggedValue;
		func_type = ddl_Element.TaggedValues.GetByName("Function Type");
		
		if(func_type != null && func_type.Value == "Replace")
			source_commands = "Replace Function " ;
		else
			source_commands = "Create Function " ;
		
		var is_mapping as EA.TaggedValue;
		is_mapping = ddl_Element.TaggedValues.GetByName("Is Mapping");
		
		if(is_mapping != null && is_mapping.Value == "True")
			source_commands += "Mapping " ;
		
		var fq_func_name as EA.TaggedValue;
		fq_func_name = ddl_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_func_name != null && fq_func_name.Value != "")
		{
			if(fq_func_name.Value.endsWith("."))
			source_commands += fq_func_name.Value ;
			else
			source_commands += "\""+fq_func_name.Value+"\"." ;
		}
		
		source_commands += "\""+ddl_Element.Name+"\"\n";		
		
		var parm_spec as EA.TaggedValue;
		parm_spec = ddl_Element.TaggedValues.GetByName("Parameter Specification");
		
		if(parm_spec != null && parm_spec.Notes != "")
			source_commands += "("+parm_spec.Notes+ ")\n";
		
		var return_data_type as EA.TaggedValue;
		return_data_type = ddl_Element.TaggedValues.GetByName("Return datatype");
		
		if(return_data_type != null && return_data_type.Notes != "")
			source_commands += "Returns "+return_data_type.Notes+"\n";
		
		var return_tab_statement as EA.TaggedValue;
		return_tab_statement = ddl_Element.TaggedValues.GetByName("Return Table Statement");
		
		if(return_tab_statement != null && return_tab_statement.Notes != "")
			source_commands += "Returns Table "+return_tab_statement.Notes+"\n";
		
		var language_clause as EA.TaggedValue;
		language_clause =  ddl_Element.TaggedValues.GetByName("Language Clause");
		
		if(language_clause != null && language_clause.Value != "")
			source_commands += "Language "+language_clause.Value+ "\n";
		
		var sql_data_access as EA.TaggedValue;
		sql_data_access = ddl_Element.TaggedValues.GetByName("Sql Data Access");
		
		if(sql_data_access != null && sql_data_access.Value != "")
			source_commands += sql_data_access.Value+ "\n";
		
		var specific_table as EA.TaggedValue;
		specific_table = ddl_Element.TaggedValues.GetByName("Specific Table");
		
		if(specific_table != null && specific_table.Value != "")
			source_commands += "Specific "+specific_table.Value+"\n";
		
		var func_class as EA.TaggedValue;
		func_class = ddl_Element.TaggedValues.GetByName("Function Class");
		
		if(func_class != null && func_class.Value != "")
			source_commands += "Class "+func_class.Value+"\n";
		
		var deterministic as EA.TaggedValue;
		deterministic = ddl_Element.TaggedValues.GetByName("Deterministic");
		
		if(deterministic != null)
		{
			if(deterministic.Value == "Yes")
				source_commands += "Deterministic \n";
			else if(deterministic.Value == "No")
				source_commands += "Not Deterministic \n";
		}
		
		var null_handling as EA.TaggedValue;
		null_handling = ddl_Element.TaggedValues.GetByName("Null Handling");
		
		if(null_handling != null && null_handling.Value == "True")
			source_commands += "Called On Null Input \n";
		
		var null_semantics as EA.TaggedValue;
		null_semantics = ddl_Element.TaggedValues.GetByName("Null Semantics");
		
		if(null_semantics != null && null_semantics.Value == "True")
			source_commands += "Returns Null On Null Input \n";
		
		var is_definer as EA.TaggedValue;
		is_definer = ddl_Element.TaggedValues.GetByName("Is Definer");
		
		if(is_definer != null && is_definer.Value == "True")
			source_commands += "SQL Security Definer \n";
		
		var coll_invoker as EA.TaggedValue;
		coll_invoker = ddl_Element.TaggedValues.GetByName("Collation Invoker");
		
		if(coll_invoker != null && coll_invoker.Value == "True")
			source_commands += "Collation Invoker Inline Type 1 \n";
		
		
		var glop_set as EA.TaggedValue;
		glop_set = 	ddl_Element.TaggedValues.GetByName("Glop Set");
		
		if(glop_set != null && glop_set.Value != "")
			source_commands += "Using Glop Set "+glop_set.Name+"\n";
		
		var is_external as EA.TaggedValue;
		is_external = ddl_Element.TaggedValues.GetByName("Is External");
		
		if(is_external != null && is_external.Value == "True")
			source_commands += "External \n";
		
		var ext_name as EA.TaggedValue;
		ext_name = ddl_Element.TaggedValues.GetByName("External Name");
		
		if(ext_name != null && ext_name.Value != "")
			source_commands += "Name "+ext_name.Value +"\n";
		
			var parm_sytle as EA.TaggedValue;
		parm_sytle = ddl_Element.TaggedValues.GetByName("Parameter Style");
		
		if(parm_sytle != null)
		{
			 if(parm_sytle.Value == "SQL")
				 source_commands += "Parameter Style SQL \n";
			 else if(parm_sytle.Value == "Td_General")
				 source_commands += "Parameter Style Td_General \n";
			 else if(parm_sytle.Value == "Java")
				 source_commands += "Parameter Style Java \n";
		}	
		
		var type_specifier as EA.TaggedValue;
		type_specifier = ddl_Element.TaggedValues.GetByName("Type Specifier");
		
		if(type_specifier != null)
		{
			if(type_specifier.Value == "Compress")
				source_commands += "For Compress\n";
			else if(type_specifier.Value == "Decompress")
				source_commands += "For Decompress\n";
		}
		
		var ex_security as EA.TaggedValue;
		ex_security = ddl_Element.TaggedValues.GetByName("External Security");
		
		if(ex_security != null && ex_security.Value != "")
			source_commands += "External Security "+ex_security.Value +"\n";
		
		var func_opt as EA.TaggedValue;
		func_opt = ddl_Element.TaggedValues.GetByName("Function Option");
	
		if(func_opt != null && func_opt.Notes != "")
			source_commands += func_opt.Notes +"\n";		
		
		var for_table as EA.TaggedValue;
		for_table = ddl_Element.TaggedValues.GetByName("For Table");
		
		if(for_table != null && for_table.Value != "")
			source_commands +=  "For "+for_table.Value+ "\n";
		
		var server_name as EA.TaggedValue;
		server_name = ddl_Element.TaggedValues.GetByName("Server Name");
		
		if(server_name != null && server_name.Value != "")
			source_commands +=  "Server "+server_name.Value+ "\n";
		
		var map_json as EA.TaggedValue;
		map_json = ddl_Element.TaggedValues.GetByName("Map Json");
		
		if(map_json != null && map_json.Value != "")
			source_commands += "Map Json("+map_json.Value+")\n";
		
		var stored_as as EA.TaggedValue;
		stored_as = ddl_Element.TaggedValues.GetByName("Stored As");
		
		if(stored_as != null)
		{
			if(stored_as.Value == "TextFile")
				source_commands += "StoredAs ( \'"+stored_as.Value+"\')\n";
			else if(stored_as.Value == "Parquet")
				source_commands += "StoredAs (\'"+stored_as.Value+"\')\n";
		}
		
		var table_list as EA.TaggedValue;
		table_list = ddl_Element.TaggedValues.GetByName("Table List");
		
		if(table_list != null && table_list.Notes != "")
			source_commands += "Using "+table_list.Notes+ "\n";
		
		var return_expr as EA.TaggedValue;
		return_expr = ddl_Element.TaggedValues.GetByName("Return Expression");
		
		if(return_expr != null && return_expr.Notes != "")
			source_commands += "Return "+return_expr.Notes+"\n";		
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
		var proc_type as EA.TaggedValue;
		proc_type = ddl_Element.TaggedValues.GetByName("Procedure Type");
		
		if(proc_type != null && proc_type.Value == "Replace")
			source_commands = "Replace Procedure " ;
		else
			source_commands = "Create Procedure " ;
		
		var fq_proc_name as EA.TaggedValue;
		fq_proc_name = ddl_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_proc_name != null && fq_proc_name.Value != "")
		{
			if(fq_proc_name.Value.endsWith("."))
			source_commands += fq_proc_name.Value;
			else
			source_commands += "\""+fq_proc_name.Value+"\".";	
		}
		
		source_commands += "\""+ddl_Element.Name+"\"\n";
		
		var parm_spec as EA.TaggedValue;
		parm_spec = ddl_Element.TaggedValues.GetByName("Parameter Specification");
		
		if(parm_spec != null && parm_spec.Notes != "")
			source_commands += "("+parm_spec.Notes+ ")\n";
		
		var language_clause as EA.TaggedValue;
		language_clause =  ddl_Element.TaggedValues.GetByName("Language Clause");
		
		if(language_clause != null && language_clause.Value != "")
			source_commands += "Language "+language_clause.Value+ "\n";
		
		var sql_data_access as EA.TaggedValue;
		sql_data_access = ddl_Element.TaggedValues.GetByName("SQL Data Access");
		
		if(sql_data_access != null && sql_data_access.Value != "")
			source_commands += sql_data_access.Value+ "\n";
		
		var dynamix_result as EA.TaggedValue;
		dynamix_result = ddl_Element.TaggedValues.GetByName("Dynamic Result Sets");
		
		if(dynamix_result != null && dynamix_result.Value != "")
			source_commands += "Dynamic Result Sets "+dynamix_result.Value+"\n";
		
		var parm_sytle as EA.TaggedValue;
		parm_sytle = ddl_Element.TaggedValues.GetByName("Parameter Style");
		
		if(parm_sytle != null)
		{
			 if(parm_sytle == "SQL")
				 source_commands += "Parameter Style SQL \n";
			 else if(parm_sytle == "Td_General")
				 source_commands += "Parameter Style Td_General \n";
			 else if(parm_sytle == "Java")
				 source_commands += "Parameter Style Java \n";
		}
		
		var glop_set as EA.TaggedValue;
		glop_set = 	ddl_Element.TaggedValues.GetByName("Glop Set");
		
		if(glop_set != null && glop_set.Value != "")
			source_commands += "Using Glop Set "+glop_set.Name+"\n";
		
		var sql_security as EA.TaggedValue;
		sql_security = ddl_Element.TaggedValues.GetByName("Sql Security");
		
		if(sql_security != null && sql_security.Value != "")
			source_commands += "SQL Security "+sql_security.Value+"\n";
		
		var is_external as EA.TaggedValue;
		is_external = ddl_Element.TaggedValues.GetByName("Is External");
		
		if(is_external != null && is_external.Value == "True")
			source_commands += "External \n";
		
		var ext_name as EA.TaggedValue;
		ext_name = ddl_Element.TaggedValues.GetByName("External Name");
		
		if(ext_name != null && ext_name.Value != "")
			source_commands += "Name "+ext_name.Value +"\n";
		
		var ex_security as EA.TaggedValue;
		ex_security = ddl_Element.TaggedValues.GetByName("External Security");
		
		if(ex_security != null && ex_security.Value != "")
			source_commands += "External Security "+ex_security.Value +"\n";
		
		var proc_statement as EA.TaggedValue;
		proc_statement = ddl_Element.TaggedValues.GetByName("procdef");
		
		if(proc_statement != null && proc_statement.Notes != "")
			source_commands += proc_statement.Notes+"\n";		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;		
}


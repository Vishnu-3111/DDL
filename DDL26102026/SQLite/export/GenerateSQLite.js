!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for SQLite database only
*/

var ssproperties = new Map();

function initialize()
{
	#sparx_initialize#
}
 
function main()
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

function elemList(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table)
{	
	try
	{
		var index = "";
		var trigger = "";
		var source_commands="";
		
		if(ddl_Element.FQStereotype == "SQLite::table") // if the given element was table 
		{
			var create_commands=[];
			
			create_commands = create_table_command(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table)
			source_commands = create_commands[0];
			index = create_commands[1];
			trigger = create_commands[2];
		}
		else if(ddl_Element.FQStereotype == "SQLite::view") // if the given element was view 
		{
			source_commands = create_view_command(ddl_Element);
		}
		
		if(source_commands != "")
			source_commands += ";";		
		
		if(index != "" )
			source_commands += "\n\n"+index;
		
		if(trigger != "" )
			source_commands += "\n\n"+trigger;
		
		source_Filepath.WriteLine(source_commands + "\n");
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
}

function create_table_command(table_element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table)
{
	var command=[];
	try
	{
		var index="";
		var trigger="";
		source_commands = "Create ";
		
		var table_type as EA.TaggedValue;
		table_type = table_element.TaggedValues.GetByName("Table Type");
		
		if(table_type != null && table_type.Value != "" && table_type.Value != "<none>")
			source_commands += table_type.Value + " ";
		
		source_commands += "Table ";
		
		var not_exists as EA.TaggedValue;
		not_exists = table_element.TaggedValues.GetByName("Not Exists");
		
		if(not_exists != null && not_exists.Value == "True")
			source_commands += "If Not Exists ";
		
		var schema_name as EA.TaggedValue;
		schema_name = table_element.TaggedValues.GetByName("Database and Schema");
		
		if(schema_name != null && schema_name.Value != "")
		{
			if(schema_name.Value.endsWith("."))
			{
				source_commands += schema_name.Value;
			}
			else
				source_commands += "\""+schema_name.Value+"\".";
		}
		
		source_commands += "\""+table_element.Name+"\"\n";
		
		if(table_element.Attributes.Count != 0)
			source_commands += "("  + "\n" ;
		
		source_commands += create_column_definition(table_element);
		
		var method_command=[];
		method_command = create_method_commanad(table_element,constraints,constraints_value,fk_connector,reference_table);
		
		source_commands += method_command[0];
		index += method_command[1];
		trigger += method_command[2];
		
		
		
		if(table_element.Attributes.Count != 0)
			source_commands +=  "\n)\n"   ;	
		
		var table_options as EA.TaggedValue;
		table_options = table_element.TaggedValues.GetByName("Table Options");
		
		if(table_options != null && table_options.Notes != "")
			source_commands += table_options.Notes + " \n";
		
		var select_query as EA.TaggedValue;
		select_query = table_element.TaggedValues.GetByName("Select Query");
		
		if(select_query != null && select_query.Notes != "")
			source_commands += "As "+select_query.Notes + "\n";
		
		var module_name as EA.TaggedValue;
		module_name = table_element.TaggedValues.GetByName("Module Name");
		
		if(module_name != null && module_name.Value != "")
			source_commands += "Using "+module_name.Value+ " \n";
		
		var module_arg as EA.TaggedValue;
		module_arg = table_element.TaggedValues.GetByName("Module Arguments");
		
		if(module_arg != null && module_arg.Notes != "")
			source_commands += "(" +module_arg.Notes+ ") \n";
		
		command[0]=source_commands;
		command[1]=index;
		command[2]=trigger;
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return command;
}

function create_column_definition(table_element)
{
	var column_commaand="";
	try
	{ 	
		for(var j=0 ; j<table_element.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = table_element.Attributes.GetAt(j);
			column_commaand += "\""+columns.Name + "\" " + columns.Type+" ";
			
			if(columns.Length != 0 || columns.Precision != 0)
			{
				if(columns.Length != 0)
					column_commaand += "("+columns.Length;
				else if(columns.Precision != 0)
					column_commaand += "("+columns.Precision;
				
				if(columns.Scale != 0)
					column_commaand += ","+columns.Scale;
				
				column_commaand +=") ";
			}
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if (NotNull)
				column_commaand += "Not Null ";
			
			default_expression = columns.Default;
			
			if(default_expression != "")
				column_commaand += "Default "+default_expression+" " ;
			
			var collate as EA.TaggedValue;
			collate = columns.TaggedValues.GetByName("Collate");
			
			if(collate != null && collate.Value != "")
				column_commaand += "Collate "+collate.Value+" ";
			
			var auto_generation as EA.TaggedValue;
			auto_generation = columns.TaggedValues.GetByName("Automatic Generation");
			
			if(auto_generation != null && auto_generation.Value == "True")
				column_commaand += "Generated Always ";
			
			var col_expr as EA.TaggedValue;
			col_expr = columns.TaggedValues.GetByName("Column Expression");
			
			if(col_expr != null && col_expr.Notes != "")
				column_commaand += "As ( "+col_expr.Notes+" ) " ;
			
			var computed_columns as EA.TaggedValue;
			computed_columns = columns.TaggedValues.GetByName("Computed Columns");
			
			if(computed_columns != null && computed_columns.Value != "" && computed_columns.Value != "<none>")
				column_commaand += computed_columns.Value + " ";	
			
			if(j != table_element.Attributes.Count - 1)
				column_commaand += ","+ "\n";
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
		return column_commaand;
		
}

function create_method_commanad(table_element,constraints,constraints_value,fk_connector,reference_table)
{
	var commands=[];
	try
	{
		var constraint_command="";
		var trigger_command="";
		var index_command="";
	
		for(var k=0 ; k<table_element.Methods.Count ; k++ )// To get the column constraints from the given table element
		{
			constraints = table_element.Methods.GetAt(k);
			
			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "index" || constraints.Stereotype == "trigger" || constraints.Stereotype == "check")
			{				
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					constraint_command+= "," +"\n";
					
					if(constraints.Name == "")						
						constraint_command += "primary key (" ; 	
					else
						constraint_command +=  "Constraint \""+constraints.Name+"\" primary key (" ; 	
					
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					constraint_command+= "," +"\n";
					
					if(constraints.Name == "")	
						constraint_command += "foreign key (";
					else 
						constraint_command +=  "Constraint \""+constraints.Name+"\" foreign key (" ; 
					
				}
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					constraint_command += "," +"\n";
					if(constraints.Name == "")						
						constraint_command += "unique (";
					else
						constraint_command +=  "Constraint \""+constraints.Name+"\" unique (" ; 
				}
				else if(constraints.Stereotype == "check") // if the constraints was check
				{
					constraint_command += "," +"\n";
					
					if(constraints.Name == "")	
						constraint_command += "Check (";
					else
						constraint_command +=  "Constraint \""+constraints.Name+"\" Check (";
					
					if(constraints.Code != "")
						constraint_command += constraints.Code  ;					
				}
				else if(constraints.Stereotype == "index") // if the constraints was index
				{
					index_command += "Create ";
					
					var is_unique as EA.TaggedValue;
					is_unique = constraints.TaggedValues.GetByName("Unique");
					
					if(is_unique != null)
					{
						if(is_unique.Value == "1" || is_unique == "TRUE")
							index_command += "Unique ";
					}
					
					index_command += "Index "
					
					var not_exists as EA.TaggedValue;
					not_exists = constraints.TaggedValues.GetByName("Not Exists");

					if(not_exists != null && not_exists.Value == "True")
						constraint_command += "If Not Exists ";
					
					var schema_name as EA.TaggedValue;
					schema_name = constraints.TaggedValues.GetByName("Database and Schema");

					if(schema_name != null && schema_name.Value != "")
					{
						if(schema_name.Value.endsWith("."))
						{
							constraint_command += schema_name.Value
						}
						else
							constraint_command += "\""+schema_name.Value+"\".";
					}
					
					index_command += "\""+constraints.Name +"\" \n On \""+ table_element.Name+"\"\n";
					
					if(constraints.Parameters.Count != 0)
						index_command += "(";
				}
				else if(constraints.Stereotype == "trigger") // if the constraints was trigger
				{
					trigger_command += "Create ";
					
					var is_temp as EA.TaggedValue;
					is_temp = constraints.TaggedValues.GetByName("Is Temporary");
					
					if(is_temp !=  null && is_temp.Value == "True")
						trigger_command += "Temporary ";
					
					trigger_command += "Trigger ";
					
					var not_exists as EA.TaggedValue;
					not_exists = constraints.TaggedValues.GetByName("Not Exists");

					if(not_exists != null && not_exists.Value == "True")
						constraint_command += "If Not Exists ";
					
					var schema_name as EA.TaggedValue;
					schema_name = constraints.TaggedValues.GetByName("Database and Schema");

					if(schema_name != null && schema_name.Value != "")
					{
						if(schema_name.Value.endsWith("."))
						{
							constraint_command += schema_name.Value
						}
						else
							constraint_command += "\""+schema_name.Value+"\".";
					}
					
					trigger_command += "\""+constraints.Name + "\" \n";
					
					var trg_time as EA.TaggedValue;
					trg_time = constraints.TaggedValues.GetByName("TRG_TIME");
					
					if(trg_time != null && trg_time.Value != "")
						trigger_command += trg_time.Value + " \n";
					
					var trg_event as EA.TaggedValue;
					trg_event = constraints.TaggedValues.GetByName("TRG_EVENT");
					
					if(trg_event != null && trg_event.Value != "")
						trigger_command +=  trg_event.Value +" ";

					if(constraints.Parameters.Count != 0)
						trigger_command += "Of ";
				}
				
				for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
				{
					constraints_value = constraints.Parameters.GetAt(l);
					
					if(l>0)
					{
						if(index_command != "" && constraints.Stereotype == "index")
							index_command += ",";	
						else if(trigger_command != "" && constraints.Stereotype == "trigger")
							trigger_command += ",";
						else
							constraint_command += ','; 						
					}
					
					if(index_command != "" && constraints.Stereotype == "index")
						index_command += "\""+constraints_value.Name+"\"";
					else if(trigger_command != "" && constraints.Stereotype == "trigger")
						trigger_command += "\""+constraints_value.Name+"\"";
					else
						constraint_command += "\""+constraints_value.Name+"\"";		
				}
				
				if(index_command != "" && constraints.Stereotype == "index")
				{
					if(constraints.Parameters.Count != 0)	
						index_command += ") \n";	
					
					var where_condition as EA.TaggedValue;
					where_condition = constraints.TaggedValues.GetByName("Where Condition");
					
					if(where_condition != null && where_condition.Notes != "")
						index_command += "Where "+where_condition.Notes+" \n";
					
					index_command += "; ";
				}
				else if(trigger_command != "" && constraints.Stereotype == "trigger")
				{
					if(constraints.Parameters.Count != 0)
						trigger_command += " ";	
					
					trigger_command += "On \""+table_element.Name+"\"\n" ;
					
					var each_row as EA.TaggedValue;
					each_row = constraints.TaggedValues.GetByName("Each Row");
					
					if(each_row != null && each_row.Value == "True")
						trigger_command += "For Each Row \n";
					
					var trg_expr as EA.TaggedValue;
					trg_expr = constraints.TaggedValues.GetByName("Trigger Expression");
					
					if(trg_expr != null && trg_expr.Notes != "")
						trigger_command += "When "+trg_expr.Notes+"\n";
					
					if(constraints.Code != "")
						trigger_command += constraints.Code;	
					
					trigger_command += "; ";
				}					
				else
					constraint_command += ") ";
				
				
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "SQLite::FK" connector
				{
					for(var f=0 ; f<table_element.Connectors.Count ; f++)
					{
						fk_connector = table_element.Connectors.GetAt(f);

						if(fk_connector.FQStereotype == "SQLite::FK" && fk_connector.ClientEnd.Role == constraints.Name)
						{
							var col_ref as EA.Method;
							
							reference_table = Repository.GetElementByID(fk_connector.SupplierID);

							constraint_command += "References \""+reference_table.Name+"\" ";
							
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

								constraint_command += "("+ref_column_names+") ";
							}
						}	
					}
					
					var on_update as EA.TaggedValue;
					on_update = constraints.TaggedValues.GetByName("Update");
					
					if(on_update != null && on_update.Value != "")
						constraint_command += "On Update "+on_update.Value+" ";
					
					var on_delete as EA.TaggedValue;
					on_delete = constraints.TaggedValues.GetByName("Delete");
					
					if(on_delete != null && on_delete.Value != "")
						constraint_command += "On Delete " +on_delete.Value+" ";
				}
			}	
		}
		commands[0]=constraint_command;
		commands[1]=index_command;
		commands[2]=trigger_command;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return commands
}

function create_view_command(view_element)
{
	var view_command = "Create " ;
	try
	{	
		var is_temp as EA.TaggedValue;
		is_temp = view_element.TaggedValues.GetByName("Is Temporary");
		
		if(is_temp !=  null && is_temp.Value == "True")
			view_command += "Temporary ";
		
		view_command += "View ";
		
		var not_exists as EA.TaggedValue;
		not_exists = view_element.TaggedValues.GetByName("Not Exists");
		
		if(not_exists !=  null && not_exists.Value == "True")
			view_command += "If Not Exists ";
		
		var schema_name as EA.TaggedValue;
		schema_name = view_element.TaggedValues.GetByName("Database and Schema");
		
		if(schema_name != null && schema_name.Value != "")
		{
			if(schema_name.Value.endsWith("."))
			{
				view_command += schema_name.Value
			}
			else
				view_command += "\""+schema_name.Value+"\".";
		}
			
		
		view_command += view_element.Name+"\n";
		
		var view_columns as EA.TaggedValue;
		view_columns = view_element.TaggedValues.GetByName("View Columns");
		
		if(view_columns != null && view_columns.Notes != "")
			view_command += "( " +view_columns.Notes+ " ) \n";
		
		var view_def as EA.TaggedValue;
		view_def = view_element.TaggedValues.GetByName("viewdef");
		
		if(view_def != null && view_def.Notes != "")
			view_command += "As "+view_def.Notes+" \n" ;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return view_command;
}



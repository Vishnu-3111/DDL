!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for Firebird database only
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
	
		source_commands="";
		var index = "";
		var trigger = "";
		
		if(ddl_Element.FQStereotype == "Firebird::table") // if the given element was table 
		{
			var create_Command=[];
			
			create_Command=create_table_command(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table);
			if(create_Command[0]!= undefined)
				source_commands=create_Command[0];
			if(create_Command[1]!= undefined)
				index=create_Command[1];
			if(create_Command[2]!= undefined)
				trigger=create_Command[2];
			
		}
		else if(ddl_Element.FQStereotype == "Firebird::view") // if the given element was view 
			source_commands += create_view_commands(ddl_Element);
		else if(ddl_Element.FQStereotype == "Firebird::sequence")		
			source_commands += create_seq_command(ddl_Element);
		else if(ddl_Element.FQStereotype == "Firebird::function")
			source_commands += function_command(ddl_Element);
		else if(ddl_Element.FQStereotype == "Firebird::procedure")
			source_commands += create_produ_command(ddl_Element);	
			
		if(source_commands != "" && ddl_Element.FQStereotype != "Firebird::function" && ddl_Element.FQStereotype != "Firebird::procedure")
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

function create_table_command(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table)
{
	var create_commands=[];
	try
	{
		var trigger="";
		
		var index="";
		
		var table_action as EA.TaggedValue;
		table_action = ddl_Element.TaggedValues.GetByName("Table Action");
		
		if(table_action != null && table_action.Value == "Recreate")
			source_commands = "ReCreate ";
		else
			source_commands = "Create ";
		
		var temp_table as EA.TaggedValue;
		temp_table = ddl_Element.TaggedValues.GetByName("Temporary Table");
		
		if(temp_table != null && temp_table.Value == "True")
			source_commands += "Global Temporary ";
		
		source_commands += "Table \""+ ddl_Element.Name +"\"\n";	
		
		var ex_file as EA.TaggedValue;
		ex_file = ddl_Element.TaggedValues.GetByName("External File");
		
		if(ex_file != null && ex_file.Value != "")
			source_commands +=  "External File "+ ex_file.Value + "\n" ;
		
		if(ddl_Element.Attributes.Count != 0)
			source_commands += "("  + "\n" ;
		
			source_commands += column_definition(ddl_Element,columns,source_commands);
		
		var Method_Command=[];
			Method_Command = create_method_commands(ddl_Element);
		
		if(Method_Command[0] != undefined)
			source_commands += Method_Command[0];
		if(Method_Command[1]!= undefined)
			index += Method_Command[1];
		if(Method_Command[2]!= undefined)
			trigger += Method_Command[2];
		
		
		if(ddl_Element.Attributes.Count != 0)
			source_commands +=  "\n)\n"   ;				
		
		source_commands += table_properties(ddl_Element)
		
		
		create_commands[0]=source_commands;
		create_commands[1]=index;
		create_commands[2]=trigger;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	return create_commands
}

function column_definition(table_Element,columns)
{
	
	var column_commands="";
	try
	{
		
		for(var j=0 ; j<table_Element.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = table_Element.Attributes.GetAt(j);
			column_commands += "\""+columns.Name + "\" " + columns.Type+" ";
			
			if(columns.Length != 0 || columns.Precision != 0)
			{
				if(columns.Length != 0)
					column_commands += "("+columns.Length;
				else if(columns.Precision != 0)
					column_commands += "("+columns.Precision;
				
				if(columns.Scale != 0)
					column_commands += ","+columns.Scale;
				
				column_commands +=") ";
			}	

			var default_value= columns.Default;
			
			if(default_value != "")
				column_commands += "Default "+default_value+" ";
			
			
			
			var charaterSet as EA.TaggedValue;
			charaterSet = columns.TaggedValues.GetByName("CharacterSet");
			
			if(charaterSet != null && charaterSet.Value != "")
				column_commands += "Character Set "+charaterSet.Value+" ";
			
			
			var collate as EA.TaggedValue;
			collate = columns.TaggedValues.GetByName("Collation");
			
			if(collate != null && collate.Value != "")
				column_commands += "Collate "+collate.Value+" ";	
			
			var arrayfield as EA.TaggedValue;
			arrayfield = columns.TaggedValues.GetByName("Array Field List");
			
			if(arrayfield != null && arrayfield.Value != "")
				column_commands += arrayfield.Value+" ";	
			
			var comp_col_def as EA.TaggedValue;
			comp_col_def = columns.TaggedValues.GetByName("Computed Column Definition");
			
			if(comp_col_def != null && comp_col_def.Notes != "")
				column_commands += comp_col_def.Notes+" " ;
			
			var column_range as EA.TaggedValue;
			column_range = columns.TaggedValues.GetByName("Column Range");
			
			if(column_range != null && column_range.Value != "")
				column_commands += "[ "+column_range.Value+" ] ";
			
			var auto_increment as EA.TaggedValue;
			auto_increment = columns.TaggedValues.GetByName("Auto Increment");
			
			if(auto_increment != null)
			{
				if(auto_increment.Value == "Always")
					column_commands += "Generated Always As Identity ";
				else if(auto_increment.Value == "Default")
				{
					column_commands += "Generated By Default As Identity ";		
					
					var identity_option as EA.TaggedValue;
						identity_option = columns.TaggedValues.GetByName("Identity Options");
					
					if(identity_option != null && identity_option.Notes != "")
						column_commands += "("+identity_option.Notes+") " ;
				}					
			}
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if (NotNull)
				column_commands += "Not Null "; 
			
			if(j != table_Element.Attributes.Count - 1)
				column_commands += ","+ "\n";	
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return column_commands;
}

function create_method_commands(table_Element)
{
	var create_commands=[];
	
	try
	{
		var index_command="";
		var trigger_command="";
		var constraint_command="";
		for(var k=0 ; k<table_Element.Methods.Count ; k++ )// To get the column constraints from the given table element
		{
			constraints = table_Element.Methods.GetAt(k);
			
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
					index_command += "Create " ;
					
					var is_unique as EA.TaggedValue;
					is_unique = constraints.TaggedValues.GetByName("Unique");
					
					if(is_unique != null)
					{
						if(is_unique.Value == "1" || is_unique == "TRUE")
							index_command += "Unique ";
					}
					
					var index_sorting as EA.TaggedValue;
					index_sorting = constraints.TaggedValues.GetByName("Index Sorting");
					
					if(index_sorting != null && index_sorting.Value != "")
						index_command +=  index_sorting.Value + " ";
					
					index_command += "Index \""+constraints.Name +"\" \n On \""+ table_Element.Name+"\"\n";
					
					if(constraints.Parameters.Count != 0)
						index_command += "(";					
					
				}		
				else if(constraints.Stereotype == "trigger") // if the constraints was trigger
				{
					trigger_command  += "Set Term ^;\n"
					var trg_action as EA.TaggedValue;
					trg_action = constraints.TaggedValues.GetByName("Trigger Action");

					if(trg_action != null && trg_action.Value == "Recreate")
						trigger_command += "ReCreate ";
					else
						trigger_command += "Create ";
					
					var is_alter as EA.TaggedValue;
					is_alter = constraints.TaggedValues.GetByName("Is Alter");

					if(is_alter != null && is_alter.Value == "True")
						trigger_command += "Or Alter ";
					
					trigger_command += "Trigger \""+constraints.Name+"\"\n";	

					var trigger_type as EA.TaggedValue;
					trigger_type = constraints.TaggedValues.GetByName("Trigger Type");
					
					var trg_status as EA.TaggedValue;
					trg_status = constraints.TaggedValues.GetByName("Trigger Status");					
						
					var trg_time as EA.TaggedValue;
					trg_time = constraints.TaggedValues.GetByName("TRG_TIME");
					
					var trg_event as EA.TaggedValue;
					trg_event = constraints.TaggedValues.GetByName("TRG_EVENT");
					
					var position as EA.TaggedValue;
					position = constraints.TaggedValues.GetByName("Position");
					
					if(trigger_type != null && trigger_type.Value == "Legacy")
					{
						trigger_command += "For \""+table_Element.Name+"\" \n";							
						
						if(trg_status != null && trg_status.Value != "")
							trigger_command += trg_status.Value+" \n";						
						
						if(trg_time != null && trg_time.Value != "")
							trigger_command += trg_time.Value+" \n";		
						
						if(trg_event != null && trg_event.Value != "")
							trigger_command += trg_event.Value + " \n" ;	
						
						if(position !=  null && position.Value != "")
							trigger_command += "Position "+position.Value + " \n" ;	
					}
					else
					{
						if(trg_status != null && trg_status.Value != "")
							trigger_command += trg_status.Value+" \n";
						
						if(trg_time != null && trg_time.Value != "")
							trigger_command += trg_time.Value+" \n";		
						
						if(trg_event != null && trg_event.Value != "")
							trigger_command += trg_event.Value + " \n" ;	

						trigger_command += "On \""+table_Element.Name+"\" \n";		

						if(position !=  null && position.Value != "")
							trigger_command += "Position "+position.Value + " \n" ;								
					}	
					
					var external_module as EA.TaggedValue;
					external_module = constraints.TaggedValues.GetByName("External Module");
					
					if(constraints.Code != "")
					{
						trigger_command += "As \n";
						
						var declaration as EA.TaggedValue;
						declaration = constraints.TaggedValues.GetByName("Declarations");

						if(declaration != null && declaration.Notes != "")
							trigger_command += declaration.Notes + " \n";

						var foward_declaration as EA.TaggedValue;
						foward_declaration  = constraints.TaggedValues.GetByName("Forward Declarations");

						if(foward_declaration != null && foward_declaration.Notes != "")
							trigger_command += foward_declaration.Notes + " \n";

						trigger_command += constraints.Code+" \n";		
					}
					
					
					var external_module as EA.TaggedValue;
					external_module = constraints.TaggedValues.GetByName("External Module");
					
					if(external_module != null && external_module.Notes != "")
						trigger_command += external_module.Notes+" \n";		
				}
				
				for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
				{
					constraints_value = constraints.Parameters.GetAt(l);
					
					if(l>0)
					{
						if(index_command != "" && constraints.Stereotype == "index")
							index_command += ",";	
						else
							constraint_command += ','; 						
					}
					
					if(index_command != "" && constraints.Stereotype == "index")
						index_command += "\""+constraints_value.Name+"\"";
					else
						constraint_command += "\""+constraints_value.Name+"\"";		
				}
				
				
				if(index_command != "" && constraints.Stereotype == "index")
				{
					if(constraints.Parameters.Count != 0)	
						index_command += ") \n";		
					
					var computed_by as EA.TaggedValue;
					computed_by = constraints.TaggedValues.GetByName("Computed By");
					
					if(computed_by !=  null && computed_by.Notes != "")
						index_command += "Computed By ( " +computed_by.Notes+ " )\n";
					
					var where_condition as EA.TaggedValue;
					where_condition = constraints.TaggedValues.GetByName("Where Condition");
					
					if(where_condition != null && where_condition.Notes != "")
							index_command += "Where " + where_condition.Notes+ "\n";
					
					index_command += "; \n\n";
				}
				else if(trigger_command != "" && constraints.Stereotype == "trigger")
				{
					trigger_command += "; ";
					
					trigger_command += "\n^\nSet Term;^ \n\n";
				}
				else
					constraint_command += ") ";
				
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "Firebird::FK" connector
				{
					for(var f=0 ; f<table_Element.Connectors.Count ; f++)
					{
						fk_connector = table_Element.Connectors.GetAt(f);

						if(fk_connector.FQStereotype == "Firebird::FK" && fk_connector.ClientEnd.Role == constraints.Name)
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
		create_commands[0]=constraint_command;
		create_commands[1]=index_command;
		create_commands[2]=trigger_command;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return create_commands;
}
function table_properties(table_element)
{
	var commands="";
	
	try
	{
		var sql_security as EA.TaggedValue;
		sql_security = table_element.TaggedValues.GetByName("Sql Security");
		
		if(sql_security != null && sql_security.Value != "" && sql_security.Value != "<none>" )
			commands += "SQL Security "+sql_security.Value+"\n";
		
		var publication as EA.TaggedValue;
		publication = table_element.TaggedValues.GetByName("Publication");
		
		if(publication != null && publication.Value != "" && publication.Value != "<none>")
			commands += publication.Value+" Publication \n";
		
		var commit_action as EA.TaggedValue;
		commit_action = table_element.TaggedValues.GetByName("Commit Action");
		
		if(commit_action != null && commit_action.Value != "" && commit_action.Value != "<none>")
			commands += "On Commit "+commit_action.Value+" Rows \n";
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return commands;
}

function create_view_commands(View_element)
{
	var View_command="";
	try
	{
		var view_action as EA.TaggedValue;
		view_action = View_element.TaggedValues.GetByName("View Action");
		
		if(view_action != null && view_action.Value == "Recreate")
			View_command = "ReCreate ";
		else
			View_command = "Create ";
		
		var is_alter as EA.TaggedValue;
		is_alter = View_element.TaggedValues.GetByName("Is Alter");
		
		if(is_alter != null && is_alter.Value == "True")
			View_command += "Or Alter ";
		
		View_command += "View \""+View_element.Name +"\"\n";			
		
		var view_columns as EA.TaggedValue;
		view_columns = View_element.TaggedValues.GetByName("View Columns");
		
		if(view_columns != null && view_columns.Notes != "")
			View_command += "( " +view_columns.Notes+ " )\n";
		
		var view_def as EA.TaggedValue;
		view_def = View_element.TaggedValues.GetByName("viewdef");
		
		if(view_def != null && view_def.Notes != "")
			View_command += "As "+view_def.Notes+"\n";
		
		var check_option as EA.TaggedValue;
		check_option = View_element.TaggedValues.GetByName("Check Option");
		
		if(check_option != null && check_option.Value == "True")
			View_command += "With Check Option \n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	return View_command;
}

function function_command(func_element)
{
	var func_command="";
	try
	{
		func_command+="Set Term ^; \n";
		
		var func_action as EA.TaggedValue;
		func_action = func_element.TaggedValues.GetByName("Function Action");

		if(func_action != null && func_action.Value == "Recreate")
			func_command += "ReCreate ";
		else
			func_command += "Create ";

		var is_alter as EA.TaggedValue;
		is_alter = func_element.TaggedValues.GetByName("Is Alter");

		if(is_alter != null && is_alter.Value == "True")
			func_command += "Or Alter ";

		func_command += "Function \""+func_element.Name +"\"\n";	

		var parameters as EA.TaggedValue;
		parameters = func_element.TaggedValues.GetByName("Parameters");

		if(parameters != null && parameters.Notes != "")
			func_command += "( " +parameters.Notes+ " )\n";

		var return_type as EA.TaggedValue;
		return_type = func_element.TaggedValues.GetByName("Returns");

		if(return_type != null && return_type.Notes != "")
			func_command += "Returns "+return_type.Notes+"\n";

		var collate as EA.TaggedValue;
		collate = func_element.TaggedValues.GetByName("Collation");

		if(collate != null && collate.Value != "")
			func_command += "Collate "+collate.Value+"\n";

		var deterministic as EA.TaggedValue;
		deterministic = func_element.TaggedValues.GetByName("Deterministic");

		if(deterministic != null && deterministic.Value == "True")
			func_command += "Deterministic \n";

		var sql_security as EA.TaggedValue;
		sql_security = func_element.TaggedValues.GetByName("Sql Security");
		
		if(sql_security != null && sql_security.Value != "" && sql_security.Value != "<none>" )
			func_command += "SQL Security "+sql_security.Value+"\n";
		
		var function_def as EA.TaggedValue;
		function_def = func_element.TaggedValues.GetByName("funcdef");

		if(function_def != null && function_def.Notes != "")
		{
			func_command += "As \n";
			
			var declaration as EA.TaggedValue;
			declaration = func_element.TaggedValues.GetByName("Declarations");
			
			if(declaration != null && declaration.Notes != "")
				func_command += declaration.Notes + "\n";
			
			var foward_declaration as EA.TaggedValue;
			foward_declaration  = func_element.TaggedValues.GetByName("Forward Declarations");
			
			if(foward_declaration != null && foward_declaration.Notes != "")
				func_command += foward_declaration.Notes + "\n";
			
			func_command += function_def.Notes+"\n";
		}
		
		var external_module as EA.TaggedValue;
		external_module = func_element.TaggedValues.GetByName("External Module");
		
		if(external_module != null && external_module.Notes != "")
			func_command += external_module.Notes+"\n";
		func_command +="^\nSet Term ;^\n"
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return func_command;
	
}

function create_seq_command(seq_Element)
{
	var seq_command="";
	try
	{
		var seq_action as EA.TaggedValue;
		seq_action = seq_Element.TaggedValues.GetByName("Sequence Action");
		
		if(seq_action != null && seq_action.Value == "Recreate")
			seq_command += "ReCreate ";
		else
			seq_command += "Create ";
		
		var is_alter as EA.TaggedValue;
		is_alter = seq_Element.TaggedValues.GetByName("Is Alter");
		
		if(is_alter != null && is_alter.Value == "True")
			seq_command += "Or Alter ";
		
		seq_command += "Sequence \""+seq_Element.Name +"\"\n";	
		
		var is_restart as EA.TaggedValue;
		is_restart  = seq_Element.TaggedValues.GetByName("Restart");
		
		if(is_restart != null && is_restart.Value == "True")
			seq_command += "Restart \n";
		
		var start_with as EA.TaggedValue;
		start_with = seq_Element.TaggedValues.GetByName("Start With");
		
		if(start_with != null && start_with.Value != "")
			seq_command += "Start With "+start_with.Value+"\n";
		
		var increment_by as EA.TaggedValue;
		increment_by = seq_Element.TaggedValues.GetByName("Increment By");
		
		if(increment_by != null && increment_by.Value != "")
			seq_command += "Increment By "+increment_by.Value+"\n";	
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return seq_command;
}

function create_produ_command(proc_element)
{
	var proc_command="";
	try
	{
		proc_command+="Set Term ^ ;\n"
		
		var proc_action as EA.TaggedValue;
		proc_action = proc_element.TaggedValues.GetByName("Procedure Action");

		if(proc_action != null && proc_action.Value == "Recreate")
			proc_command += "ReCreate ";
		else
			proc_command += "Create ";

		var is_alter as EA.TaggedValue;
		is_alter = proc_element.TaggedValues.GetByName("Is Alter");

		if(is_alter != null && is_alter.Value == "True")
			proc_command += "Or Alter ";

		proc_command += "Procedure \""+proc_element.Name +"\"\n";	
		
		var parameters as EA.TaggedValue;
		parameters = proc_element.TaggedValues.GetByName("Parameters");

		if(parameters != null && parameters.Notes != "")
			proc_command += "( " +parameters.Notes+ " )\n";

		var return_type as EA.TaggedValue;
		return_type = proc_element.TaggedValues.GetByName("Returns");

		if(return_type != null && return_type.Notes != "")
			proc_command += "Returns ( "+return_type.Notes+" ) \n";
		
		var sql_security as EA.TaggedValue;
		sql_security = proc_element.TaggedValues.GetByName("Sql Security");
		
		if(sql_security != null && sql_security.Value != "" && sql_security.Value != "<none>" )
			proc_command += "SQL Security "+sql_security.Value+"\n";
		
		var proc_def as EA.TaggedValue;
		proc_def = proc_element.TaggedValues.GetByName("procdef");

		if(proc_def != null && proc_def.Notes != "")
		{
			proc_command += "As \n";
			
			var declaration as EA.TaggedValue;
			declaration = proc_element.TaggedValues.GetByName("Declarations");
			
			if(declaration != null && declaration.Notes != "")
				proc_command += declaration.Notes + "\n";
			
			var foward_declaration as EA.TaggedValue;
			foward_declaration  = proc_element.TaggedValues.GetByName("Forward Declarations");
			
			if(foward_declaration != null && foward_declaration.Notes != "")
				proc_command += foward_declaration.Notes + "\n";
			
			proc_command += proc_def.Notes+"\n";
		}
		
		var external_module as EA.TaggedValue;
		external_module = proc_element.TaggedValues.GetByName("External Module");
		
		if(external_module != null && external_module.Notes != "")
			proc_command += external_module.Notes+"\n";	
		
		proc_command += "^\n Set Term;^\n"
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return proc_command;
}
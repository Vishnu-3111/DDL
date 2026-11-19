!INC Local Scripts.EAConstants-JScript

/* 
  This script is applied for Snowflake database only
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
		if(ddl_Element.FQStereotype == "Snowflake::table") // if the given element was table 
			source_commands = create_table_command(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table);
		else if(ddl_Element.FQStereotype == "Snowflake::view") // if the given element was view 
			source_commands = create_view_command(ddl_Element);
		else if(ddl_Element.FQStereotype == "Snowflake::sequence") // if the given element was sequence 
			source_commands = create_seq_command(ddl_Element);
		else if(ddl_Element.FQStereotype == "Snowflake::function") // if the given element was function 
			source_commands = create_function_command(ddl_Element)
		else if(ddl_Element.FQStereotype == "Snowflake::procedure") // if the given element was procedure 
			source_commands = create_procedure_command(ddl_Element)	;
		
		source_commands += ";";	
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
	source_commands = "Create ";
	try
	{
		var is_replace as EA.TaggedValue;
		is_replace = table_element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			source_commands += "Or Replace ";
		
		var is_alter  as EA.TaggedValue;
		is_alter = table_element.TaggedValues.GetByName("Is Alter");
		
		if(is_alter != null && is_alter.Value == "True")
			source_commands += "Or Alter ";
		
		var table_type as EA.TaggedValue;
		table_type = table_element.TaggedValues.GetByName("Table Type");
		
		if(table_type != null && (table_type.Value != "" && table_type.Value != "<none>") )
			source_commands += table_type.Value+ " ";
		
		var temp_opt as EA.TaggedValue;
		temp_opt = table_element.TaggedValues.GetByName("Temporary Option");
		
		if(temp_opt != null && (temp_opt.Value != "" && temp_opt.Value != "<none>"))
			source_commands += temp_opt.Value+" ";
		
		source_commands +=  "Table ";

		var not_exist as EA.TaggedValue;
		not_exist = table_element.TaggedValues.GetByName("Not Exists");
		
		if(not_exist != null && not_exist.Value == "True")
			source_commands += "If Not Exists " ;
		
		var schema_database as EA.TaggedValue;
		schema_database = table_element.TaggedValues.GetByName("Schema and Database");
		
		if(schema_database != null && schema_database.Value != "")
		{
			if(schema_database.Value.endsWith("."))
				source_commands += schema_database.Value ;
			else
				source_commands += schema_database.Value+"." ;
		}
		
		source_commands += "\""+table_element.Name+"\"\n";
		
		if(table_element.Attributes.Count != 0)
			source_commands += "("  + "\n" ;
		
		source_commands += column_defenition(table_element);
		
		source_commands += create_method_commands(table_element,constraints,constraints_value,fk_connector,reference_table);
		
		if(table_element.Attributes.Count != 0)
			source_commands +=  "\n)\n" ;
		
		source_commands += create_table_conn_commands(table_element);
			
		source_commands += table_properties(table_element,table_type);
	}	
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return source_commands;
		
}

function column_defenition(table_element)
{
		var column_command = "";
	try
	{
		for(var j=0 ; j<table_element.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = table_element.Attributes.GetAt(j);
			column_command +="\""+ columns.Name + "\" " + columns.Type+" ";
			
			if(columns.Length != 0 || columns.Precision != 0)
			{
				if(columns.Length != 0)
					column_command += "("+columns.Length;
				else if(columns.Precision != 0)
					column_command += "("+columns.Precision;
				
				if(columns.Scale != 0)
					column_command += ","+columns.Scale;
				
				column_command +=") ";
			}
			var array_type_field as EA.TaggedValue;
			array_type_field = columns.TaggedValues.GetByName("Array Field List");
			
			if(array_type_field != null && array_type_field.Value != "")
				column_command += array_type_field.Value+" ";
			
			var object_type_field as EA.TaggedValue;
			object_type_field = columns.TaggedValues.GetByName("Object Field List");
			
			if(object_type_field != null && object_type_field.Value != "")
				column_command += object_type_field.Value+" ";
			
			var map_type_field as EA.TaggedValue;
			map_type_field = columns.TaggedValues.GetByName("Map Field List");
			
			if(map_type_field != null && map_type_field.Value != "")
				column_command += map_type_field.Value+" ";
			
			// To include additional commands from the "Snowflake::column" Tagged values in column_command
			var column_expr as EA.TaggedValue;
			column_expr = columns.TaggedValues.GetByName("Column Expression");
			
			if(column_expr != null && column_expr.Notes != "")
				column_command += "As "+column_expr.Notes+" ";
			
			var collate as EA.TaggedValue;
			collate = columns.TaggedValues.GetByName("Collate");
			
			if(collate != null && collate.Value != "")
				column_command += "Collate "+collate.Value+" ";
			
			var comment as EA.TaggedValue;
			comment = columns.TaggedValues.GetByName("Comment");
			
			if(comment != null && comment.Value != "")
				column_command += "Comment "+comment.Value+" ";
			
			
			var default_expr = columns.Default;
			
			if(default_expr != "")
				column_command += "Default "+default_expr+" ";
			
			var column_modifier as EA.TaggedValue;
			column_modifier = columns.TaggedValues.GetByName("Column Modifier");
			
			if(column_modifier != null && column_modifier.Notes != "")
				column_command += column_modifier.Notes+" ";
			
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if (NotNull)
				column_command += "Not Null ";
			
			var masking_policy as EA.TaggedValue;
			masking_policy = columns.TaggedValues.GetByName("Masking Policy");
			
			if(masking_policy != null && masking_policy.Notes != "")
				column_command += "With Masking Policy "+masking_policy.Notes+" ";
			
			var tag as EA.TaggedValue;
			tag = columns.TaggedValues.GetByName("Tag");
			
			if(tag != null && tag.Notes != "")
				column_command += "With Tag ( "+masking_policy.Notes+" ) ";
			
			if(j != table_element.Attributes.Count - 1)
				column_command += ","+ "\n";				
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return column_command;
}

function create_method_commands(table_element,constraints,constraints_value,fk_connector,reference_table)
{
		var method_command="";
	try
	{
	
		for(var k=0 ; k<table_element.Methods.Count ; k++ )// To get the column constraints from the given table element
		{
			
			constraints = table_element.Methods.GetAt(k);
			if(constraints.Stereotype == "check")
			{
				method_command += "," +"\n";
				if(constraints.Name != null && constraints.Name != "")
					method_command += "CONSTRAINT " + constraints.Name +" ";
				method_command += "Check (";
					
					if(constraints.Code != "")
						method_command += constraints.Code +")" ;
			}
			
			if(constraints.Parameters.Count != 0 )
			{
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					method_command+= "," +"\n";
					
					if(constraints.Name == "")						
						method_command += "primary key (" ; 	
					else
						method_command +=  "Constraint \""+constraints.Name+"\" primary key (" ; 
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					method_command+= "," +"\n";
					
					if(constraints.Name == "")	
						method_command += "foreign key (";
					else 
						method_command +=  "Constraint \""+constraints.Name+"\" foreign key (" ; 
				}
				else if(constraints.Stereotype == "unique")// if the constraints was unique
				{
					method_command+= "," +"\n";
					
					if(constraints.Name == "")	
						method_command += "Unique (";
					else 
						method_command +=  "Constraint \""+constraints.Name+"\" Unique (" ; 
				}
				else if(constraints.Stereotype == "check") // if the constraints was check
				{
					method_command += "," +"\n";
					
						method_command += "Check (";
					
					if(constraints.Code != "")
						method_command += constraints.Code ;
					
				}
				if(constraints.Stereotype != "index")
				{
					for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
					{
						constraints_value = constraints.Parameters.GetAt(l);
						
						if(l>0)
							method_command += ','; 
						
						method_command+= "\""+constraints_value.Name+"\"";						
					}	
				}
				method_command += ") ";	
				
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "Snowflake::FK" connector
				{
					for(var f=0 ; f<table_element.Connectors.Count ; f++)
					{
						fk_connector = table_element.Connectors.GetAt(f);

						if(fk_connector.FQStereotype == "Snowflake::FK" && fk_connector.ClientEnd.Role == constraints.Name)
						{
							var col_ref as EA.Method;
							
							reference_table = Repository.GetElementByID(fk_connector.SupplierID);
							
							method_command += "References ";
							
							var ref_schema_database as EA.TaggedValue;
								ref_schema_database = reference_table.TaggedValues.GetByName("Schema and Database");
								
								if(ref_schema_database!=null && ref_schema_database.Value!="")
								{
									if(ref_schema_database.Value.endsWith("."))
										method_command += ref_schema_database.Value
									else
										method_command += "\""+ref_schema_database.Value+"\".";
								}

							method_command += "\""+reference_table.Name+"\" ";
							
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

								method_command += "("+ref_column_names+") ";
							}
						}	
					}
					
					var on_update as EA.TaggedValue;
					on_update = constraints.TaggedValues.GetByName("Update");
					
					if(on_update != null && on_update.Value != "")
						method_command += "On Update "+on_update.Value+" ";
					
					var on_delete as EA.TaggedValue;
					on_delete = constraints.TaggedValues.GetByName("Delete");
					
					if(on_delete != null && on_delete.Value != "")
						method_command += "On Delete " +on_delete.Value+" ";	
				}
			}			
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return method_command;
}

function create_table_conn_commands(table_element)
{
	var conn_command="";
	try
	{
		var table_con as EA.Connector;
		var connected_table as EA.Element;
		
		for(var l=0 ; l<table_element.Connectors.Count; l++)  // To include the Like,clone table command from the Connectors list
		{
			table_con = table_element.Connectors.GetAt(l);
			
			if(table_element.ElementID == table_con.ClientID)
			{
				connected_table = Repository.GetElementByID(table_con.SupplierID);	
				
				if(table_con.FQStereotype == "Snowflake::like")	
					conn_command += "Like \""+connected_table.Name + "\"\n";
				else if(table_con.FQStereotype == "Snowflake::clone")
				{
					conn_command += "Clone \""+connected_table.Name + "\"\n";
					
					var clone_time as EA.TaggedValue;
					clone_time = table_con.TaggedValues.GetByName("Clone Timing");
					
					if(clone_time != null && (clone_time.Value != "" && clone_time.Value != "<none>"))
						conn_command += clone_time.Value +"\n" ;
					
					var clone_option as EA.TaggedValue;
					clone_option = table_con.TaggedValues.GetByName("Clone Options");
					
					if(clone_option != null && clone_option.Notes != "")
						conn_command += "( "+clone_option.Notes+" )\n";	
				}
			}
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return conn_command;
}

function table_properties(table_element,table_type)
{
	var source_commands="";
	
	try
	{
		var clustering as EA.TaggedValue;
		clustering = table_element.TaggedValues.GetByName("Clustering");
		
		if(clustering != null && clustering.Notes != "")
			source_commands += "Cluster By ( " +clustering.Notes+ " )\n";
		
		var file_format as EA.TaggedValue;
		file_format = table_element.TaggedValues.GetByName("File Format");
		
		if(file_format != null && file_format.Value != "" && file_format.Value != "<none>")
		{
			if(table_type.Value == "External")
			{
				source_commands += "File_Format = (\nTYPE = "+file_format.Value+" \n";
				
				var file_format_options as EA.TaggedValue;
					file_format_options = table_element.TaggedValues.GetByName("FileFormatTypeOption");
				if(file_format_options!=null && file_format_options.Notes!="")
				{
					source_commands += file_format_options.Notes+" \n";
				}
				source_commands+=")\n"
			}				
			else
			{
				source_commands += "Stage_File_Format = (\nTYPE =  "+file_format.Value+"\n";		
				
				var file_format_options as EA.TaggedValue;
					file_format_options = table_element.TaggedValues.GetByName("FileFormatTypeOption");
				if(file_format_options!=null && file_format_options.Notes!="")
				{
					source_commands += file_format_options.Notes+" \n";
				}
				source_commands+=")\n"
			}				
		}
		var file_format_Name as EA.TaggedValue;
		file_format_Name = table_element.TaggedValues.GetByName("File Format Name");
		
		if(file_format_Name!=null && file_format_Name.Value!="")
		{
			source_commands += "File_Format = ( \n FORMAT_NAME = "+file_format_Name.Value+" \n)";
		}
		
		var format_Reference as EA.TaggedValue;
		format_Reference = table_element.TaggedValues.GetByName("FormatReference");
		
		if(format_Reference!=null && format_Reference.Value!="")
		{
			source_commands += "File_Format =" +format_Reference.Value+" \n";
		}
		
		var copy_option as EA.TaggedValue;
		copy_option = table_element.TaggedValues.GetByName("Copy Options");
		
		if(copy_option != null && copy_option.Notes != "")
			source_commands += "Stage_Copy_Option = ( "+copy_option.Notes+" )\n";
			
		var Schema_evaluation as EA.TaggedValue;
		Schema_evaluation = table_element.TaggedValues.GetByName("Schema Evolution");
		
		if(Schema_evaluation != null && Schema_evaluation.Value == "True")
			source_commands += "ENABLE_SCHEMA_EVOLUTION =  "+Schema_evaluation.Value+" \n";
		
		var data_retention as EA.TaggedValue;
		data_retention = table_element.TaggedValues.GetByName("Data Retention");
		
		if(data_retention != null && data_retention.Value != "")
			source_commands += "Data_Retention_Time_In_Days = "+data_retention.Value+"\n";
		
		var data_extension as EA.TaggedValue;
		data_extension = table_element.TaggedValues.GetByName("Data Extension");
			
		if(data_extension != null && data_extension.Value != "")
			source_commands += "Max_Data_Extension_Time_In = "+data_extension.Value+"\n";
		
		var change_tracking as EA.TaggedValue;
		change_tracking = table_element.TaggedValues.GetByName("Change Tracking");		
		
		if(change_tracking != null && (change_tracking.Value != "" && change_tracking.Value != "<none>"))
			source_commands += "Check_Tracking = "+change_tracking.Value+"\n" ;
		
		var default_collation as EA.TaggedValue;
		default_collation = table_element.TaggedValues.GetByName("Default Collation");
		
		if(default_collation != null && default_collation.Value)
			source_commands += "Default_DDL_Collation = "+default_collation.Value+"\n" ;
		
		var copy_grant as EA.TaggedValue;
		copy_grant = table_element.TaggedValues.GetByName("Copy Grant");
		
		if(copy_grant != null && copy_grant.Value == "True")
			source_commands += "Copy Grants \n";
		
		var using_temp as EA.TaggedValue;
		using_temp = table_element.TaggedValues.GetByName("Using Template");
		
		if(using_temp != null && using_temp.Notes != "")
			source_commands += "Using Template "+using_temp.Notes+"\n";
		
		var refresh_mode as EA.TaggedValue;
		refresh_mode = table_element.TaggedValues.GetByName("Refresh Mode");
		
		if(refresh_mode != null && (refresh_mode.Value != "" && refresh_mode.Value != "<none>"))
			source_commands +=  "Refresh_mode =  "+refresh_mode.Value+"\n";	
		
		var initialize as EA.TaggedValue;
		initialize = table_element.TaggedValues.GetByName("Initialize");
		
		if(initialize != null && (initialize.Value != "" && initialize.Value != "<none>"))
			source_commands +=  "Initialize =  "+initialize.Value+"\n";	
		
		var row_access_policy as EA.TaggedValue;
		row_access_policy = table_element.TaggedValues.GetByName("Row Access Policy");
		
		if(row_access_policy != null && row_access_policy.Notes != "")
			source_commands +=  "With Row Access Policy "+row_access_policy.Notes+"\n";		
			
		var aggressionPolicy as EA.TaggedValue;
		aggressionPolicy = table_element.TaggedValues.GetByName("Aggregation Policy");
		
		if(aggressionPolicy != null && aggressionPolicy.Notes != "")
			view_command +=  "With Aggregation Policy "+aggressionPolicy.Notes+"\n";
		
		var tag as EA.TaggedValue;
		tag = table_element.TaggedValues.GetByName("Tag");
		
		if(tag != null && tag.Notes != "")
			source_commands +=  "With Tag ( "+tag.Notes+" )\n";
		
		var comment as EA.TaggedValue;
		comment = table_element.TaggedValues.GetByName("Comment");
		
		if(comment != null && comment.Value != "")
			source_commands += "Comment = "+comment.Value+"\n" ;
		
		var trg_lag as EA.TaggedValue;
		trg_lag = table_element.TaggedValues.GetByName("Target Lag");
		
		if(trg_lag != null && trg_lag.Value != "")
			source_commands += "Target_Lag = "+trg_lag.Value+"\n";
		
		var warehouse as EA.TaggedValue;
		warehouse = table_element.TaggedValues.GetByName("Warehouse");
		
		if(warehouse != null && warehouse.Value !="")
			source_commands += "Warehouse = "+warehouse.Value+"\n";
		
		var cloud_parm as EA.TaggedValue;
		cloud_parm = table_element.TaggedValues.GetByName("Cloud Parameter");
		
		if(cloud_parm != null && cloud_parm.Value != "")
			source_commands += "Integration = "+cloud_parm.Value+"\n";
		 
		var partition_by as EA.TaggedValue;
		partition_by = table_element.TaggedValues.GetByName("Partition By");
		
		if(partition_by != null && partition_by.Notes != "")
			source_commands += "Partition By ( "+partition_by.Notes+" )\n";
		
		var location as EA.TaggedValue;
		location = table_element.TaggedValues.GetByName("Location");
		
		if(location != null && location.Value != "")
		{
			if(table_type.Value == "Iceberg")
					source_commands += "Base_Location = "+location.Value+" \n";
			else
				source_commands += "With Location = "+location.Value+" \n";
		}
		
		var refresh_on_connector as EA.TaggedValue;
		refresh_on_connector = table_element.TaggedValues.GetByName("Refresh On Create");
		
		if(refresh_on_connector != null && (refresh_on_connector.Value != "" && refresh_on_connector.Value != "<none>"))
			source_commands += "Refresh_On_Create = "+refresh_on_connector.Value+"\n";
		
		var auto_refresh as EA.TaggedValue;
		auto_refresh = table_element.TaggedValues.GetByName("Auto Refresh");
		
		if(auto_refresh != null && (auto_refresh.Value != "" && auto_refresh.Value != "<none>"))
			source_commands += "Auto_Refresh = "+auto_refresh.Value+"\n"; 
		
		var pattern as EA.TaggedValue;
		pattern = table_element.TaggedValues.GetByName("Pattern");
		
		if(pattern != null && pattern.Value != "")
			source_commands += "Pattern = "+pattern.Value+"\n";
		
		var aws_sns as EA.TaggedValue;
		aws_sns = table_element.TaggedValues.GetByName("AWS SNS");
		
		if(aws_sns != null && aws_sns.Value != "")
			source_commands += "AWS_SNS_Topic = "+aws_sns.Value+"\n";
		
		var user_specified as EA.TaggedValue;
		user_specified = table_element.TaggedValues.GetByName("User Specified");
		
		if(user_specified != null && user_specified.Value == "True")
			source_commands += "Partition_Type = User_Specified \n" ;
		
		var delta as EA.TaggedValue;
		delta = table_element.TaggedValues.GetByName("Delta");
		
		if(delta != null && delta.Value == "True")
			source_commands += "Table_Format = Delta \n" ;
		
		var ex_volume as EA.TaggedValue;
		ex_volume = table_element.TaggedValues.GetByName("External Volume");
		
		if(ex_volume != null && ex_volume.Value != "")
			source_commands += "External_Volume = "+ex_volume.Value+ "\n" ;
		
		var catalog as EA.TaggedValue;
		catalog = table_element.TaggedValues.GetByName("Catalog");
		
		if(catalog != null && catalog.Value != "")
			source_commands += "Catalog = "+catalog.Value+ "\n" ;		
		
		var ex_catalog as EA.TaggedValue;
		ex_catalog = table_element.TaggedValues.GetByName("External Catalog");
		
		if(ex_catalog != null && ex_catalog.Notes != "")
			source_commands +=  ex_catalog.Notes + "\n";
		
		var select_query as EA.TaggedValue;
		select_query = table_element.TaggedValues.GetByName("Select Query");
		
		if(select_query != null && select_query.Notes != "")
			source_commands += "As "+select_query.Notes+"\n" ;

	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return source_commands;
}

function create_view_command(view_element)
{
		var view_command = "Create ";
	try
	{
		var is_replace as EA.TaggedValue;
		is_replace = view_element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			view_command += "Or Replace ";
		
		var secure as EA.TaggedValue;
		secure = view_element.TaggedValues.GetByName("Secure");
		
		if(secure != null && secure.Value == "True")
			view_command += "Secure ";
		
		var recursive as EA.TaggedValue;
		recursive = view_element.TaggedValues.GetByName("Recursive");
		
		if(recursive != null && recursive.Value == "True")
			view_command += "Recursive ";
		
		var tempOption as EA.TaggedValue;
		tempOption = view_element.TaggedValues.GetByName("Temporary Option");
		
		if(tempOption != null && tempOption.Value != "" && tempOption.Value!="<none>")
			view_command += tempOption.Value+" ";
		
		var mat_view as EA.TaggedValue;
		mat_view = view_element.TaggedValues.GetByName("Materialized");
		
		if(mat_view != null && mat_view.Value == "True")
			view_command += "Materialized ";		
		
		view_command += "View ";
		
		var not_exist as EA.TaggedValue;
		not_exist = view_element.TaggedValues.GetByName("Not Exists");
		
		if(not_exist != null && not_exist.Value == "True")
			view_command += "If Not Exists " ;
		
		var schema_database as EA.TaggedValue;
		schema_database = view_element.TaggedValues.GetByName("Schema and Database");
		
		if(schema_database != null && schema_database.Value != "")
		{
			if(schema_database.Value.endsWith("."))
				view_command += schema_database.Value ;
			else
				view_command += "\""+schema_database.Value+"\"." ;
		}
		
		view_command +="\""+ view_element.Name+"\"\n";
		
		var view_columns as EA.TaggedValue;
		view_columns = view_element.TaggedValues.GetByName("View Columns");
		
		if(view_columns != null && view_columns.Notes != "")
			view_command += "( "+view_columns.Notes+" )\n";
		
		var view_constraint as EA.TaggedValue;
		view_constraint  = view_element.TaggedValues.GetByName("View Constraints");
		
		if(view_constraint != null && view_constraint.Notes != "")
			view_command += view_constraint.Notes+"\n";
		
		var row_access_policy as EA.TaggedValue;
		row_access_policy = view_element.TaggedValues.GetByName("Row Access Policy");
		
		if(row_access_policy != null && row_access_policy.Notes != "")
			view_command +=  "With Row Access Policy "+row_access_policy.Notes+"\n";		
			
		var aggressionPolicy as EA.TaggedValue;
		aggressionPolicy = view_element.TaggedValues.GetByName("Aggregation Policy");
		
		if(aggressionPolicy != null && aggressionPolicy.Notes != "")
			view_command +=  "With Aggregation Policy "+aggressionPolicy.Notes+"\n";	
		
		var tag as EA.TaggedValue;
		tag = view_element.TaggedValues.GetByName("Tag");
		
		if(tag != null && tag.Notes != "")
			view_command +=  "With Tag ( "+tag.Notes+" )\n";
		
		var Clusterby as EA.TaggedValue;
		Clusterby = view_element.TaggedValues.GetByName("Clustering");
		
		if(Clusterby != null && Clusterby.Notes != "")
			view_command +=  "Cluster By ( "+Clusterby.Notes+" )\n";
		
		var copy_grant as EA.TaggedValue;
		copy_grant = view_element.TaggedValues.GetByName("Copy Grants");
		
		if(copy_grant != null && copy_grant.Value == "True")
			view_command += "Copy Grants \n";
		
		var comment as EA.TaggedValue;
		comment = view_element.TaggedValues.GetByName("Comment");
			
		if(comment != null && comment.Value != "")
			view_command += "Comment = "+comment.Value+"\n";
			
		var view_definition as EA.TaggedValue;
		view_definition = view_element.TaggedValues.GetByName("viewdef");
		
		if(view_definition != null && view_definition.Notes != "")
			view_command += "As "+view_definition.Notes+"\n";
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return view_command;
}

function create_seq_command(Seq_element)
{
	var seq_command	= "Create ";
		
	try
	{
		var is_replace as EA.TaggedValue;
		is_replace = Seq_element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			seq_command += "Or Replace ";
		
		seq_command += "Sequence ";
		
		var not_exist as EA.TaggedValue;
		not_exist = Seq_element.TaggedValues.GetByName("Not Exists");
		
		if(not_exist != null && not_exist.Value == "True")
			seq_command += "If Not Exists " ;
		
		var schema_database as EA.TaggedValue;
		schema_database = Seq_element.TaggedValues.GetByName("Schema and Database");
		
		if(schema_database != null && schema_database.Value != "")
		{
			if(schema_database.Value.endsWith("."))
				seq_command += schema_database.Value ;
			else
				seq_command += "\""+schema_database.Value+"\"." ;
		}
		
		seq_command += "\""+Seq_element.Name+"\"\n";
		
		seq_command += clone_sequence_command(Seq_element) ;
		
		
		var initial_value as EA.TaggedValue;
		initial_value = Seq_element.TaggedValues.GetByName("Initial Value");
		
		if(initial_value != null && initial_value.Value != "")
			seq_command += "Start With = "+initial_value.Value+"\n";
		
		var seq_interval as EA.TaggedValue;
		seq_interval = Seq_element.TaggedValues.GetByName("Sequence Interval");
		
		if(seq_interval != null && seq_interval.Value != "")
			seq_command += "Increment By = "+seq_interval.Value+"\n";
		
		var seq_mode as EA.TaggedValue;
		seq_mode = Seq_element.TaggedValues.GetByName("Sequencing mode");
		
		if(seq_mode != null && (seq_mode.Value !="" && seq_mode.Value != "<none>"))
			seq_command += seq_mode.Value+"\n";
		
		var cache_size as EA.TaggedValue;
		cache_size = Seq_element.TaggedValues.GetByName("Cache Size");
		
		if(cache_size != null && cache_size.Value != "")
			seq_command +=  "Cache Size "+cache_size.Value+"\n";
		
		var no_cycle as EA.TaggedValue;
		no_cycle = Seq_element.TaggedValues.GetByName("No Cycle");
		
		if(no_cycle != null && no_cycle.Value == "True")
			seq_command += "No Cycle \n";		
		
		var comment as EA.TaggedValue;
		comment = Seq_element.TaggedValues.GetByName("Comment");
			
		if(comment != null && comment.Value != "")
			seq_command += "Comment = "+comment.Value+"\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return seq_command;
}

function create_function_command(func_element)
{
		var func_command = "Create ";
	try
	{
		var is_replace as EA.TaggedValue;
		is_replace = func_element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			func_command += "Or Replace ";
		
		var DataMetric as EA.TaggedValue;
		DataMetric = func_element.TaggedValues.GetByName("Data Metric");
		
		if(DataMetric != null && DataMetric.Value == "True")
			func_command += "Data Metric ";
		
		var temp_func as EA.TaggedValue;
		temp_func = func_element.TaggedValues.GetByName("Temporary Function");
		
		if(temp_func != null && temp_func.Value == "True")
			func_command += "Temporary " ;
		
		var secure as EA.TaggedValue;
		secure = func_element.TaggedValues.GetByName("Secure");
		
		if(secure != null && secure.Value == "True")
			func_command += "Secure ";
		
		var ex_func as EA.TaggedValue;
		ex_func =  func_element.TaggedValues.GetByName("External Function");
		
		if(ex_func != null && ex_func.Value == "True")
			func_command += "External ";
		
		var is_Aggregate as EA.TaggedValue;
		is_Aggregate = func_element.TaggedValues.GetByName("Is Aggregate");
		
		if(is_Aggregate != null && is_Aggregate.Value == "True")
			func_command += "Aggregate ";
		
		func_command += "Function ";
		
		var not_exist as EA.TaggedValue;
		not_exist = func_element.TaggedValues.GetByName("Not Exists");
		
		if(not_exist != null && not_exist.Value == "True")
			func_command += "If Not Exists " ;
		
		var schema_database as EA.TaggedValue;
		schema_database = func_element.TaggedValues.GetByName("Schema and Database");
		
		if(schema_database != null && schema_database.Value != "")
		{
			if(schema_database.Value.endsWith("."))
				func_command += schema_database.Value ;
			else
				func_command += "\""+schema_database.Value+"\"." ;
		}
		
		func_command += "\""+func_element.Name+"\"\n";	

		var args as EA.TaggedValue;
		args = func_element.TaggedValues.GetByName("Arguments");
		
		func_command +=  "( "
		
		if(args != null && args.Notes != "")
			func_command += args.Notes;
		
		func_command +=  ")\n" ;
		
		var copy_grant as EA.TaggedValue;
		copy_grant = func_element.TaggedValues.GetByName("Copy Grant");
		
		if(copy_grant != null && copy_grant.Value == "True")
			func_command += "Copy Grants \n";
		
		var returns as EA.TaggedValue;
		returns = func_element.TaggedValues.GetByName("Returns");
		
		if(returns != null && returns.Notes != "")
			func_command += "Returns "+returns.Notes+"\n";
		
		var nullcheck as EA.TaggedValue;
		nullcheck = func_element.TaggedValues.GetByName("Returns State");
		
		if(nullcheck != null && nullcheck.Value != ""&&nullcheck.Value!="<none>")
			func_command += +nullcheck.Value+"\n";
		
		var language as EA.TaggedValue;
		language = func_element.TaggedValues.GetByName("Language");
		
		if(language != null && language.Value != "")
			func_command += "Language "+language.Value+"\n";
		
		var null_behaviour as EA.TaggedValue;
		null_behaviour = func_element.TaggedValues.GetByName("Null Behaviour");
		
		if(null_behaviour != null)
		{
			if(null_behaviour.Value == "Permissive")
				func_command += "Called On Null Input \n";
			else if(null_behaviour.Value == "Nullable")
				func_command += "Returns Null On Null Input \n";
			else if(null_behaviour.Value == "Strict")
				func_command += "Strict \n";
		}
		
		var mutability_classification as EA.TaggedValue;
		mutability_classification = func_element.TaggedValues.GetByName("Mutability Classification");
		
		if(mutability_classification != null && (mutability_classification.Value != "" && mutability_classification.Value != "<none>"))
			func_command += mutability_classification.Value+"\n" ;
		
		var memoizable as EA.TaggedValue;
		memoizable  = func_element.TaggedValues.GetByName("Memoizable");
		
		if(memoizable != null && memoizable.Value == "True")
			func_command += "Memoizable \n";
		
		var run_time as EA.TaggedValue;
		run_time = func_element.TaggedValues.GetByName("Runtime Version");
		
		if(run_time != null && run_time.Value != "")
			func_command += "Runtime_Version = "+run_time.Value+"\n";		
		
		var service_name as EA.TaggedValue;
		service_name = func_element.TaggedValues.GetByName("Service Name");
		
		if(service_name != null && service_name.Value != "")
			func_command += "Service Name = "+service_name.Value+"\n";
		
		var endpoint as EA.TaggedValue;
		endpoint = func_element.TaggedValues.GetByName("End Point");
		
		if(endpoint != null && endpoint.Value != "")
			func_command += "EndPoint = "+endpoint.Value+"\n";
		
		var comment as EA.TaggedValue;
		comment = func_element.TaggedValues.GetByName("Comment");
			
		if(comment != null && comment.Value != "")
			func_command += "Comment = "+comment.Value+"\n";
		
		var imports as EA.TaggedValue;
		imports = func_element.TaggedValues.GetByName("Imports");
		
		if(imports != null && imports.Notes != "")
			func_command += "Imports = ( "+imports.Notes+" )\n";
		
		var packages as EA.TaggedValue;
		packages = func_element.TaggedValues.GetByName("Packages");
		
		if(packages != null && packages.Notes != "")
			func_command += "Packages = ( " +packages.Notes+ " )\n";
		
		var handler as EA.TaggedValue;
		handler = func_element.TaggedValues.GetByName("Handler");
		
		if(handler != null && handler.Value != "")
			func_command += "Handler = "+handler.Value+"\n";
		
		var ExternalAccessIntegration as EA.TaggedValue;
		ExternalAccessIntegration = func_element.TaggedValues.GetByName("External Access Integration");
		
		if(ExternalAccessIntegration != null && ExternalAccessIntegration.Notes != "")
			func_command += "ExternalAccessIntegration = ( " +ExternalAccessIntegration.Notes+ " )\n";
		
		var Secrets as EA.TaggedValue;
		Secrets = func_element.TaggedValues.GetByName("Secrets");
		
		if(Secrets != null && Secrets.Notes != "")
			func_command += "Secrets = ( " +Secrets.Notes+ " )\n";
		
		var target_path as EA.TaggedValue;
		target_path = func_element.TaggedValues.GetByName("Target Path");
		
		if(target_path != null && target_path.Value != "")
			func_command += "Target_Path = "+target_path.Value+"\n";
		
		var api_integration as EA.TaggedValue;
		api_integration = func_element.TaggedValues.GetByName("Api Integration");
		
		if(api_integration != null && api_integration.Value != "")
			func_command += "Api_Integration = "+api_integration.Value+"\n";
		
		var headers as EA.TaggedValue;
		headers = func_element.TaggedValues.GetByName("Headers");
			
		if(headers != null && headers.Notes != "")
			func_command += "Headers = ( "+headers.Notes+" )\n";
		
		var context_headers as EA.TaggedValue;
		context_headers = func_element.TaggedValues.GetByName("Context Headers");
		
		if(context_headers != null && context_headers.Notes != "")
			func_command += "Context_Headers = ( "+context_headers.Notes+" )\n";
		
		var max_batch_rows as EA.TaggedValue;
		max_batch_rows = func_element.TaggedValues.GetByName("Max Batch Rows");
		
		if(max_batch_rows != null && max_batch_rows.Value != "")
			func_command += "Max_Batch_Rows = "+max_batch_rows+"\n";
		
		var compression as EA.TaggedValue;
		compression = func_element.TaggedValues.GetByName("Compression");
		
		if(compression != null && compression.Value != "")
			func_command += "Compression = "+compression.Value+"\n";
			
		var req_translator as EA.TaggedValue;
		req_translator = func_element.TaggedValues.GetByName("Request Translator");
		
		if(req_translator != null && req_translator.Value != "")
			func_command += "Request_Translator = "+req_translator.Value+"\n";
		
		var res_translator as EA.TaggedValue;
		res_translator = func_element.TaggedValues.GetByName("Response Translator");
		
		if(res_translator != null && res_translator.Value != "")
			func_command += "Response_Translator = "+res_translator.Value+"\n";
		
		var func_def as EA.TaggedValue;
		func_def = func_element.TaggedValues.GetByName("funcdef");
		
		if(func_def != null && func_def.Notes != "")
			func_command += "As "+func_def.Notes+"\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
		return func_command;
}

function create_procedure_command(proce_Element)
{
		var proce_command = "Create ";
	try
	{
		var is_replace as EA.TaggedValue;
		is_replace = proce_Element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			proce_command += "Or Replace ";
		
		var secure as EA.TaggedValue;
		secure = proce_Element.TaggedValues.GetByName("Secure");
		
		if(secure != null && secure.Value == "True")
			proce_command += "Secure ";
		
		proce_command += "Procedure ";
		
		var schema_database as EA.TaggedValue;
		schema_database = proce_Element.TaggedValues.GetByName("Schema and Database");
		
		if(schema_database != null && schema_database.Value != "")
		{
			if(schema_database.Value.endsWith("."))
				proce_command += schema_database.Value ;
			else
				proce_command += "\""+schema_database.Value+"\"." ;
		}
		
		proce_command += "\""+proce_Element.Name+"\"\n";
		
		var args as EA.TaggedValue;
		args = proce_Element.TaggedValues.GetByName("Arguments");
		
		proce_command +=  "( "
		
		if(args != null && args.Notes != "")
			proce_command += args.Notes;
		
		proce_command +=  ")\n" ;
		
		var copy_grant as EA.TaggedValue;
		copy_grant = proce_Element.TaggedValues.GetByName("Copy Grant");
		
		if(copy_grant != null && copy_grant.Value == "True")
			proce_command += "Copy Grants \n";
		
		var returns as EA.TaggedValue;
		returns = proce_Element.TaggedValues.GetByName("Returns");
		
		if(returns != null && returns.Notes != "")
			proce_command += "Returns "+returns.Notes+"\n";
		
		var language as EA.TaggedValue;
		language = proce_Element.TaggedValues.GetByName("Language");
		
		if(language != null && language.Value != "")
			proce_command += "Language "+language.Value+"\n";
		
		var run_time as EA.TaggedValue;
		run_time = proce_Element.TaggedValues.GetByName("Runtime Version");
		
		if(run_time != null && run_time.Value != "")
			proce_command += "Runtime_Version = "+run_time.Value+"\n";	
		
		var packages as EA.TaggedValue;
		packages = proce_Element.TaggedValues.GetByName("Packages");
		
		if(packages != null && packages.Notes != "")
			proce_command += "Packages = ( " +packages.Notes+ " )\n";
		
		var imports as EA.TaggedValue;
		imports = proce_Element.TaggedValues.GetByName("Imports");
		
		if(imports != null && imports.Notes != "")
			proce_command += "Imports = ( "+imports.Notes+" )\n";
		
		var handler as EA.TaggedValue;
		handler = proce_Element.TaggedValues.GetByName("Handler");
		
		if(handler != null && handler.Value != "")
			proce_command += "Handler = "+handler.Value+"\n";
		
		var ExternalAccessIntergration as EA.TaggedValue;
		ExternalAccessIntergration = proce_Element.TaggedValues.GetByName("External Access Integration");
		
		if(ExternalAccessIntergration != null && ExternalAccessIntergration.Notes != "")
			proce_command += "External_Access_Integrations = ("+ExternalAccessIntergration.Notes+")\n";
		
		var Secrets as EA.TaggedValue;
		Secrets = proce_Element.TaggedValues.GetByName("Secrets");
		
		if(Secrets != null && Secrets.Notes != "")
			proce_command += "Secrets = ("+Secrets.Notes+")\n";
		
		
		var target_path as EA.TaggedValue;
		target_path = proce_Element.TaggedValues.GetByName("Target Path");
		
		if(target_path != null && target_path.Value != "")
			proce_command += "Target_Path = "+target_path.Value+"\n";
		
		var null_behaviour as EA.TaggedValue;
		null_behaviour = proce_Element.TaggedValues.GetByName("Null Behaviour");
		
		if(null_behaviour != null)
		{
			if(null_behaviour.Value == "Permissive")
				proce_command += "Called On Null Input \n";
			else if(null_behaviour.Value == "Nullable")
				proce_command += "Returns Null On Null Input \n";
			else if(null_behaviour.Value == "Strict")
				proce_command += "Strict \n";
		}
		
		var mutability_classification as EA.TaggedValue;
		mutability_classification = proce_Element.TaggedValues.GetByName("Mutability Classification");
		
		if(mutability_classification != null && (mutability_classification.Value != "" && mutability_classification.Value != "<none>"))
			proce_command += mutability_classification.Value+"\n" ;
		
		var comment as EA.TaggedValue;
		comment = proce_Element.TaggedValues.GetByName("Comment");
		
		if(comment != null && comment.Value != "")
			proce_command += "Comment = "+comment.Value+"\n";
		
		var exce_as as EA.TaggedValue;
		exce_as = proce_Element.TaggedValues.GetByName("Execute As");
		
		if(exce_as != null && (exce_as.Value != "" && exce_as.Value != "<none>"))
			proce_command += "Execute As "+exce_as.Value+"\n";
		
		var pro_def as EA.TaggedValue;
		pro_def = proce_Element.TaggedValues.GetByName("procdef");
		
		if(pro_def != null && pro_def.Notes != "")
			proce_command += "As "+pro_def.Notes+"\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return proce_command;
}

function clone_sequence_command(seq_element)
{
	var clone_command="";
	try
	{
		var SEQ_conn as EA.Connector;
		var connected_seq as EA.Element;
		
				for(var l=0 ; l<seq_element.Connectors.Count; l++)
				{
					var SEQ_conn = seq_element.Connectors.GetAt(l);
					
					if(seq_element.ElementID == SEQ_conn.ClientID)
					{
						connected_seq = Repository.GetElementByID(SEQ_conn.SupplierID);
						
						if(SEQ_conn.FQStereotype == "Snowflake::clone")	
							clone_command += "clone \""+connected_seq.Name + "\"\n";
					}
				}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return clone_command ;
}
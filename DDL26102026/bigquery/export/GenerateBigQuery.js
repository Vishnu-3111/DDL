!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for Big Query database only
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
		var index="";
		source_commands="";
		
		if(ddl_Element.FQStereotype == "BigQuery::table") // if the given element was table 
		{
			var create_command=[];
			 create_command = create_Table_commands(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table);
			if(create_command[0]!= undefined)
				source_commands = create_command[0];
						
			if(create_command[1]!= undefined)
				index=create_command[1];
					
		}
		else if(ddl_Element.FQStereotype == "BigQuery::view") // if the given element was view 
			source_commands += Create_view_commands(ddl_Element);
		else if(ddl_Element.FQStereotype == "BigQuery::function")
			source_commands += Create_function_commands(ddl_Element);
		else if(ddl_Element.FQStereotype == "BigQuery::procedure")
			source_commands += Create_procedure_commands(ddl_Element);
				
		source_commands += ";";	
		
		if(index != "" )
				source_commands += "\n\n"+index;
		
		source_Filepath.WriteLine(source_commands + "\n");
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
}

function create_Table_commands(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table)
{
	var create_Command=[];
	source_commands = "Create ";
	var index="";
	try
	{
		// To get is replace and table type value to initiate the Create table commands
		var is_replace as EA.TaggedValue;
		is_replace = ddl_Element.TaggedValues.GetByName("IsReplace");
		
		if(is_replace != null && is_replace.Value == "True")
			source_commands += "Or Replace ";
		
		var table_type as EA.TaggedValue;
		table_type = ddl_Element.TaggedValues.GetByName("Table Type");		
					
		if(table_type != null && table_type.Value == "External")
			source_commands += "External Table ";
		else if(table_type != null && table_type.Value == "Temporary")
			source_commands += "Temporary Table ";
		else if(table_type != null && table_type.Value == "Snapshot")
			source_commands += "Snapshot Table ";	
		else
			source_commands += "Table "; // To write the Create table Command if table type is none or others 		
		
		var not_exist as EA.TaggedValue; // To check if the table element have Not Exist property
		not_exist = ddl_Element.TaggedValues.GetByName("Not Exist");
		
		if(not_exist != null &&  not_exist.Value == "True")
			source_commands += "If Not Exists ";
		
		var table_datasource as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		table_datasource = ddl_Element.TaggedValues.GetByName("Datasource");
		
		var table_dataset as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		table_dataset = ddl_Element.TaggedValues.GetByName("Dataset");
		
		if(table_datasource != null && table_datasource.Value != "")
		{
			if(table_datasource.Value.endsWith("."))
			source_commands += table_datasource.Value;
			else
			source_commands += "`"+table_datasource.Value+"`.";
		}
		if(table_dataset != null && table_dataset.Value != "")
		{
			if(table_dataset.Value.endsWith("."))
				source_commands += table_dataset.Value;
			else
			source_commands += "`"+table_dataset.Value+"`.";
		}
		source_commands += "`"+ddl_Element.Name +"`\n";
		
		
			source_commands += column_Definition(ddl_Element)
		var commands =[];
			commands = methodsdefinition(ddl_Element,commands);
		if(commands[0] != undefined)
			source_commands +=commands[0];
		if(commands[1] != undefined)
			index += commands[1];
				
		if(ddl_Element.Attributes.Count != 0)
			source_commands +=  "\n)\n"   ;	
		
		source_commands += like_table_command(ddl_Element);
		
		source_commands += table_additional_properties(ddl_Element);
		
		create_Command[0]=source_commands;
		create_Command[1]=index;
			
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return create_Command;
}

function column_Definition( Elements)
{
	var column_command="";
	try
	{
				
		if(Elements.Attributes.Count != 0)
			column_command += "("  + "\n" ;
		
		for(var j=0 ; j<Elements.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = Elements.Attributes.GetAt(j);
			column_command += "`"+columns.Name + "` " + columns.Type+" ";
			
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
			
			// To include additional commands from the "BigQuery::column" Tagged values in column_command
			var struct_field as EA.TaggedValue;
			struct_field = columns.TaggedValues.GetByName("Struct Field List");
			
			if(struct_field != null && struct_field.Notes != "" )
				column_command += struct_field.Notes+" ";
			
			var array_field as EA.TaggedValue;
			array_field = columns.TaggedValues.GetByName("Array Field List");
			
			if(array_field != null && array_field.Notes != "" )
				column_command += array_field.Notes+" ";
			
			var Range_type as EA.TaggedValue;
			Range_type = columns.TaggedValues.GetByName("Range type");
			
			if(Range_type != null && Range_type.Value != "" )
				column_command += Range_type.Value+" ";
			
			var collate as EA.TaggedValue;			
			collate = columns.TaggedValues.GetByName("Collate");
			
			if(collate != null && collate.Value != "")
				column_command += "String Collate "+collate.Value+" ";
			
			var col_default = columns.Default;
			
			if( col_default != "")
				column_command += "Default " +col_default+" ";
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if (NotNull)
				column_command += "Not Null ";
			
			var column_option as EA.TaggedValue;
			column_option = columns.TaggedValues.GetByName("Column Options");
			
			if(column_option != null && column_option.Notes != "")
				column_command += "Options ("+column_option.Notes+")";			
					
			if(j != Elements.Attributes.Count - 1)
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
function methodsdefinition(Elements,commands)
{
	try
	{		
		var index="";
		var medthod_commands="";
		
		for(var k=0 ; k<Elements.Methods.Count ; k++ )// To get the column constraints from the given table element
		{			
			constraints = Elements.Methods.GetAt(k);
			
			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "index")
			{
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					medthod_commands+= "," +"\n";
						
						medthod_commands += "primary key (" ; 	
					
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					medthod_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						medthod_commands += "foreign key (";
					else 
						medthod_commands +=  "Constraint `"+constraints.Name+"` foreign key (" ; 
				}
				else if(constraints.Stereotype == "index") // if the constraints was index
				{
					index += "Create " ;
					var index_type as EA.TaggedValue;
						index_type =constraints.TaggedValues.GetByName("Index Type");
					if(index_type != null &&  index_type.Value != "<none>")
						index += index_type.Value + " Index ";
					
					var not_exist as EA.TaggedValue;  // To check if the index have Not Exist property
						not_exist = constraints.TaggedValues.GetByName("Not Exist");

					if(not_exist != null &&  not_exist.Value == "True")
						index += "If Not Exists ";	
					index +="`"+constraints.Name+"` on ";
					
					index +="`" ;
					var table_datasource as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
						table_datasource = Elements.TaggedValues.GetByName("Datasource");
		
					var table_dataset as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
						table_dataset = Elements.TaggedValues.GetByName("Dataset");
		
						if(table_datasource != null && table_datasource.Value != "")
						{
							index += "`"+table_datasource.Value+"`.";
						}
						if(table_dataset != null && table_dataset.Value != "")
						{
							index += "`"+table_dataset.Value+"`.";
						}
					
					index += "`"+Elements.Name+"` (" ;
				}
				
				for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
				{
					constraints_value = constraints.Parameters.GetAt(l);
					if(l>0)
					{
						if(index != "" && constraints.Stereotype == "index")
							index += ",";
						else
							medthod_commands += ','; 
					} 	
					
					if(index != "" && constraints.Stereotype == "index")
						index += constraints_value.Name;					
					else
						medthod_commands+= "`"+constraints_value.Name+"`";	
				}
				
				if(index != "" && constraints.Stereotype == "index")
				{
					var is_allcolumn as EA.TaggedValue;
					is_allcolumn = constraints.TaggedValues.GetByName("All Columns");

					if(is_allcolumn != null && is_allcolumn.Value == "True")
						index +="All Columns" ;
				
					index += ") \n";	
						
					var index_option as EA.TaggedValue;
					index_option = constraints.TaggedValues.GetByName("Index Options");
					
					if(index_option != null && index_option.Notes != "")
						index +=  "Options (\n"+index_option.Notes+"\n)\n";
					
					index += "; \n\n";
				}						 
				else
					medthod_commands += ") ";	
					
				if(constraints.Stereotype == "PK")
					medthod_commands +="NOT ENFORCED"
						
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "BigQuery::FK" connector
				{
					for(var f=0 ; f<Elements.Connectors.Count ; f++)
					{
						fk_connector = Elements.Connectors.GetAt(f);

						if(fk_connector.FQStereotype == "BigQuery::FK" && fk_connector.ClientEnd.Role == constraints.Name)
						{
							var col_ref as EA.Method;
							
							reference_table = Repository.GetElementByID(fk_connector.SupplierID);
							medthod_commands += "References ";
							var datasource as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
								datasource = reference_table.TaggedValues.GetByName("Datasource");
		
							var dataset as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
								dataset = reference_table.TaggedValues.GetByName("Dataset");
		
									if(datasource != null && datasource.Value != "")
									{
										medthod_commands +="`"+ datasource.Value+"`.";
									}
									if(dataset != null && dataset.Value != "")
									{
										medthod_commands += "`"+dataset.Value+"`.";
									}
									
								medthod_commands +=	"`"+reference_table.Name+"` ";
							
							var destRole = fk_connector.SupplierEnd.Role;

							var is_valid_constraint = false;

							for(var c=0 ; c<reference_table.Methods.Count ; c++)
							{
								col_ref = reference_table.Methods.GetAt(c);

								if(col_ref.Name == destRole )
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

								medthod_commands += "("+ref_column_names+") NOT ENFORCED";
							}
						}	
					}
				}
			}
		}
	
		commands[0]=medthod_commands;
		
		commands[1]=index;
		
	
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
return commands;
}

function like_table_command(elements)
{
	var like_commands="";
	try
	{
		var table_con as EA.Connector;
		var connected_table as EA.Element;
		for(var l=0 ; l<elements.Connectors.Count; l++)  // To include the Like,Copy,clone table command from the Connectors list
		{
			table_con = elements.Connectors.GetAt(l);
			
			var target_fqname as EA.TaggedValue;			
			
			if(elements.ElementID == table_con.ClientID)
			{
				connected_table = Repository.GetElementByID(table_con.SupplierID);	
				
				if(table_con.FQStereotype == "BigQuery::like")	
					like_commands += "Like " ;
				else if(table_con.FQStereotype == "BigQuery::clone")
					like_commands += "Clone ";
				else if(table_con.FQStereotype == "BigQuery::copy")
					like_commands += "Copy ";	
				if(like_commands!="")
				{
					var datasource as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
						datasource = connected_table.TaggedValues.GetByName("Datasource");
		
					var dataset as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
						dataset = connected_table.TaggedValues.GetByName("Dataset");
		
					if(datasource != null && datasource.Value != "")
					{
						like_commands += "`"+datasource.Value+"`.";
					}
					if(dataset != null && dataset.Value != "")
					{
						like_commands += "`"+dataset.Value+"`.";
					}
					
					like_commands+= "`"+connected_table.Name + "`\n";
				}
							
			}	
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return like_commands ;
	
}

function table_additional_properties(table_element)
{
	var table_pro_command="";
	try
	{
		// To include additional commands from the "BigQuery::table" Tagged values in table_pro_command
		var collate as EA.TaggedValue;
		collate = table_element.TaggedValues.GetByName("Collate");
		
		if(collate != null && collate.Value != "")
			table_pro_command += "Default Collate "+collate.Value+"\n";
		
		var partition_by as EA.TaggedValue;
		partition_by = table_element.TaggedValues.GetByName("Partition By");
		
		if(partition_by != null && partition_by.Value != "")
			table_pro_command += "Partition By "+partition_by.Value+"\n";
		
		var cluster_by as EA.TaggedValue;
		cluster_by = table_element.TaggedValues.GetByName("Cluster By");
		
		if(cluster_by != null && cluster_by.Value != "")
			table_pro_command += "Cluster By "+cluster_by.Value+"\n";
		
		var system_time as EA.TaggedValue;
		system_time = table_element.TaggedValues.GetByName("System Time");
		
		if(system_time != null && system_time.Value != "" )  
			table_pro_command += "For System_Time As Of "+system_time.Value+"\n";
		
		var connection_with as EA.TaggedValue;
		connection_with = table_element.TaggedValues.GetByName("Connection With");
		
		if(connection_with != null && connection_with.Value != "" )  
			table_pro_command += "With Connection "+connection_with.Value+"\n";
		
		var partition_column as EA.TaggedValue;
		partition_column = table_element.TaggedValues.GetByName("Partition Columns With");
		
		if(partition_column != null && partition_column.Notes != "")
			table_pro_command += "With Partition Columns "+partition_column.Notes+"\n";		
		
		var table_option as EA.TaggedValue;
		table_option = table_element.TaggedValues.GetByName("Table Options");
		
		if(table_option != null && table_option.Notes != "")
			table_pro_command += "Options (\n"+table_option.Notes+"\n)\n";
		
		var select_query as EA.TaggedValue;
		select_query = table_element.TaggedValues.GetByName("Select Query");
		
		if(select_query != null && select_query.Notes != "")
			table_pro_command += "As "+select_query.Notes+"\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
		return table_pro_command;
}

function Create_view_commands(Elements)
{
	var view_commands = "Create ";
	try
	{
	
		// To get is replace and view type value to initiate the Create View commands
		
		var is_replace as EA.TaggedValue;
		is_replace = Elements.TaggedValues.GetByName("IsReplace");
		
		if(is_replace != null && is_replace.Value == "True")
			view_commands += "Or Replace ";
		
		var view_type as EA.TaggedValue;
		view_type = Elements.TaggedValues.GetByName("View Type");		
					
		if(view_type != null && view_type.Value == "Materialized")
			view_commands += "Materialized ";
		
		view_commands += "View ";			
		
		var not_exist as EA.TaggedValue;  // To check if the view element have Not Exist property
		not_exist = Elements.TaggedValues.GetByName("Not Exist");
		
		if(not_exist != null &&  not_exist.Value == "True")
			view_commands += "If Not Exists ";	
			
		var datasource as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		datasource = Elements.TaggedValues.GetByName("Datasource");
		
		var dataset as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		dataset = Elements.TaggedValues.GetByName("Dataset");
		
		if(datasource != null && datasource.Value != "")
		{
			view_commands += "`"+datasource.Value+"`.";
		}
		if(dataset != null && dataset.Value != "")
		{
			view_commands += "`"+dataset.Value+"`.";
		}
		
		view_commands += "`"+Elements.Name +"`\n";	

		// To include additional commands from the "BigQuery::view" Tagged values in view_commands
		var view_columns as EA.TaggedValue;
		view_columns = Elements.TaggedValues.GetByName("View Columns");
		
		if(view_columns != null && view_columns.Notes != "")
			view_commands += "(\n" + view_columns.Notes+"\n)\n";
		
		var partition_by as EA.TaggedValue;
		partition_by = Elements.TaggedValues.GetByName("Partition By");
		
		if(partition_by != null && partition_by.Value != "")
			view_commands += "Partition By "+partition_by.Value+"\n";
		
		var cluster_by as EA.TaggedValue;
		cluster_by = Elements.TaggedValues.GetByName("Cluster By");
		
		if(cluster_by != null && cluster_by.Value != "")
			view_commands += "Cluster By "+cluster_by.Value+"\n";
		
		var view_options as EA.TaggedValue;
		view_options = Elements.TaggedValues.GetByName("View Options");
		
		if(view_options != null && view_options.Notes != "" )
			view_commands += "Options (\n" + view_options.Notes+"\n)\n";
		
		var view_def as EA.TaggedValue;
		view_def = Elements.TaggedValues.GetByName("viewdef");
		
		if(view_def != null && view_def.Notes != "")
			view_commands += "As "+ view_def.Notes+"\n";
	}
catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}

	return view_commands;
}

function Create_function_commands(func_Element)
{
	var function_commands = "Create ";
	try
	{	
		// To get is replace and function type value to initiate the Create Function commands
		
		var is_replace as EA.TaggedValue;
		is_replace = func_Element.TaggedValues.GetByName("IsReplace");
		
		if(is_replace != null && is_replace.Value == "True")
			function_commands += "Or Replace ";
		
		var is_temporary as EA.TaggedValue;
		is_temporary = func_Element.TaggedValues.GetByName("Is Temporary");
		
		if(is_temporary != null && is_temporary.Value == "True")
			function_commands += "Temporary ";
		
		var func_type as EA.TaggedValue;
		func_type = func_Element.TaggedValues.GetByName("Function Type");
		
		if(func_type != null && func_type.Value == "Aggregate")
				function_commands += "Aggregate Function ";
		else if(func_type != null && func_type.Value == "Table")
			function_commands += "Table Function ";
		else
			function_commands += "Function ";	// To write the Create function Command if function type is none or others 	
		
		var not_exist as EA.TaggedValue; // To check if the view element have Not Exist property
		not_exist = func_Element.TaggedValues.GetByName("Not Exist");
		
		if(not_exist != null &&  not_exist.Value == "True")
			function_commands += "If Not Exists ";	
			
		var datasource as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		datasource = func_Element.TaggedValues.GetByName("Datasource");
		
		var dataset as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		dataset = func_Element.TaggedValues.GetByName("Dataset");
		
		if(datasource != null && datasource.Value != "")
		{
			function_commands += "`"+datasource.Value+"`.";
		}
		if(dataset != null && dataset.Value != "")
		{
			function_commands += "`"+~dataset.Value+"`.";
		}
		
		function_commands += "`"+func_Element.Name +"` \n";
		
		// To include additional commands from the "BigQuery::function" Tagged values in function_commands
		
		var func_param as EA.TaggedValue;
		func_param = func_Element.TaggedValues.GetByName("Function Parameters");
		
		if(func_param != null && func_param.Notes != "")
			function_commands += "(\n" +func_param.Notes+"\n)\n" ;
		
		var return_value as EA.TaggedValue;
		return_value = func_Element.TaggedValues.GetByName("Return");
		
		if(return_value != null && return_value.Value != "")
			function_commands += "Returns "+return_value.Value+"\n";
		
		var determinism_specifier as EA.TaggedValue;
		determinism_specifier = func_Element.TaggedValues.GetByName("Determinism Specifier");
		
		if(determinism_specifier != null && determinism_specifier.Value != "" )
			function_commands +=  determinism_specifier.Value + "\n";
		
		var remote_connection as EA.TaggedValue;
		remote_connection = func_Element.TaggedValues.GetByName("Remote Connection");
		
		if(remote_connection != null && remote_connection.Value != "")
			function_commands += "Remote With Connection "+remote_connection.Value+"\n" ;
		
		var language as EA.TaggedValue;
		language = func_Element.TaggedValues.GetByName("Language");
		
		if(language != null && language.Value !="")
			function_commands += "Language "+language.Value+"\n";
		
		var func_option as EA.TaggedValue;
		func_option = func_Element.TaggedValues.GetByName("Function Options");
			
		if(func_option != null && func_option.Notes != "" )
			function_commands += "Options (\n"+func_option.Notes+"\n)\n" ;
		
		var func_def as EA.TaggedValue;
		func_def = func_Element.TaggedValues.GetByName("funcdef");
		
		if(func_def != null && func_def.Notes != "")
			function_commands += "As "+func_def.Notes+"\n";
	
	}
	catch (e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
	return function_commands;
		
}

function Create_procedure_commands(elements)
{
	var procedure_commands = "Create ";
	try
	{		
		// To get is replace  value to initiate the Create procedure commands
		var is_replace as EA.TaggedValue;
		is_replace = elements.TaggedValues.GetByName("IsReplace");
		
		if(is_replace != null && is_replace.Value == "True")
			procedure_commands += "Or Replace "; 
		
		procedure_commands += "Procedure "
		
		// To include additional commands from the "BigQuery::procedure" Tagged values in procedure_commands
		var not_exist as EA.TaggedValue;
		not_exist = elements.TaggedValues.GetByName("Not Exist");
		
		if(not_exist != null &&  not_exist.Value == "True")
			procedure_commands += "If Not Exists ";
		
		var datasource as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		datasource = elements.TaggedValues.GetByName("Datasource");
		
		var dataset as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		dataset = elements.TaggedValues.GetByName("Dataset");
		
		if(datasource != null && datasource.Value != "")
		{
			procedure_commands += "`"+datasource.Value+"`.";
		}
		if(dataset != null && dataset.Value != "")
		{
			procedure_commands += "`"+dataset.Value+"`.";
		}
		
		procedure_commands += "`"+elements.Name +"` \n";
		
		var proc_arg as EA.TaggedValue;
		proc_arg = elements.TaggedValues.GetByName("Procedure Arguments");
		
		if(proc_arg != null && proc_arg.Notes != "")
			procedure_commands += "(\n" +proc_arg.Notes +"\n)\n";
		else
			procedure_commands += "()\n";
		
		var ExternalSecurity as EA.TaggedValue;
		ExternalSecurity = elements.TaggedValues.GetByName("External Security");
		
		if(ExternalSecurity != null && ExternalSecurity.Value != "")
			procedure_commands += "External Security " +ExternalSecurity.Value +"\n";
		
		var connection_with as EA.TaggedValue;
		connection_with = elements.TaggedValues.GetByName("Connection With");
		
		if(connection_with != null && connection_with.Value != "")
			procedure_commands += "With Connection " +connection_with.Value+ "\n";
		
		var proc_option as EA.TaggedValue;
		proc_option = elements.TaggedValues.GetByName("Procedure Options");
		
		if(proc_option != null && proc_option.Notes != "")
			procedure_commands += "Options(\n" +proc_option.Notes+ "\n)\n";
		
		var language as EA.TaggedValue;
		language = elements.TaggedValues.GetByName("Language");
		
		if(language != null && language.Value !="")
			procedure_commands += "Language "+language.Value+"\n";
		
		var proc_def as EA.TaggedValue;
		proc_def = elements.TaggedValues.GetByName("procdef");
		
		if(proc_def != null && proc_def.Notes != "")
			procedure_commands += proc_def.Notes + "\n";
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return procedure_commands;
		
}

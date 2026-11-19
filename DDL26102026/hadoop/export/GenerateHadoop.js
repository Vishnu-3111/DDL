!INC Local Scripts.EAConstants-JScript

/* 
  This script is applied for Hadoop database only
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

function elemList(ddl_Element, source_commands, columns, constraints, constraints_value, source_Filepath, fk_connector, reference_table) 
{ 
	try
	{
		var index = "";
		source_commands="";
		if(ddl_Element.FQStereotype == "Hadoop::table") // if the given element was table 
		{
			var create_commands=[];
			create_commands = Create_table(ddl_Element, source_commands, columns, constraints, constraints_value, source_Filepath, fk_connector, reference_table);
			if(create_commands[0]!=undefined)
			source_commands += create_commands[0];
			if(create_commands[1]!=undefined)
			index += create_commands[1];
		}
		else if(ddl_Element.FQStereotype == "Hadoop::view") // if the given element was view 
			source_commands += create_view_commands(ddl_Element);
		else if(ddl_Element.FQStereotype == "Hadoop::function")
			source_commands += create_function_commands(ddl_Element);
				
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

function Create_table(table_ELement, source_commands, columns, constraints, constraints_value, source_Filepath, fk_connector, reference_table)
{
	var commands=[];
	try
	{
		var index="";
	
		var table_type as EA.TaggedValue;
		table_type = table_ELement.TaggedValues.GetByName("Table Type");	
		
		if(table_type != null && table_type.Value == "Temporary")
			source_commands = "Create Temporary Table ";
		else if(table_type != null && table_type.Value == "External")
			source_commands = "Create External Table ";
		else if(table_type != null && table_type.Value == "Transactional")
			source_commands = "Create Transactional Table ";	
		else
			source_commands = "Create Table "; // To write the Create table Command if table type is none or others 	
			
		var not_exist as EA.TaggedValue; // To check if the table element have Not Exist property
		not_exist = table_ELement.TaggedValues.GetByName("Not Exist");
		
		if(not_exist != null &&  not_exist.Value == "True")
			source_commands += "If Not Exists ";
		
		var fq_tableName as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		fq_tableName = table_ELement.TaggedValues.GetByName("Schema and Database");
		
		if(fq_tableName != null && fq_tableName.Value != "")
		{
			
			if(fq_tableName.Value.endsWith("."))
				source_commands += fq_tableName.Value;
			else
				source_commands += "`"+fq_tableName.Value+"`.";
		}
		
		source_commands += "`"+table_ELement.Name +"`\n";
		
		if(table_ELement.Attributes.Count != 0)
			source_commands += "("  + "\n" ;
		
		source_commands += create_column_commands(table_ELement);
		
		var method_commands=[];
			method_commands = create_method_command(table_ELement);
		 if(method_commands[0]!=undefined)
			source_commands += method_commands[0];
		 if(method_commands[1]!=undefined)
			index += method_commands[1];
				
		if(table_ELement.Attributes.Count != 0)
			source_commands +=  "\n)\n"   ;			
			
		source_commands += table_Properties(table_ELement);
		commands[0]=source_commands;
		commands[1]=index;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return commands;
}

function create_column_commands(table_ELement)
{
	var column_command="";
	try
	{
	
		for(var j=0 ; j<table_ELement.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = table_ELement.Attributes.GetAt(j);
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
			
			var field_type as EA.TaggedValue;
			field_type = columns.TaggedValues.GetByName("Field Value Types");
		
			if(field_type != null && field_type.Notes != "")
				column_command += field_type.Notes+" ";
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
			if (NotNull)
				column_command += "Not Null ";
			
			// To include additional commands from the "Hadoop::column" Tagged values in column_command
			var default_value as EA.TaggedValue;
			default_value = columns.TaggedValues.GetByName("Default");
		
			if(default_value != null && default_value.Value != "")
				column_command += "Default "+default_value.Value+" ";
			
			var column_comment as EA.TaggedValue;
			column_comment = columns.TaggedValues.GetByName("Column Comment");
		
			if(column_comment != null && column_comment.Notes != "")
				column_command += "Comment "+column_comment.Notes+" ";
			
			if(j != table_ELement.Attributes.Count - 1)
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

function create_method_command(table_ELement)
{
	var commands=[];
	
	try
	{	
		var constraint_commands="";
		var index_command="";
	
		for(var k=0 ; k<table_ELement.Methods.Count ; k++ )// To get the column constraints from the given table element
		{
			constraints = table_ELement.Methods.GetAt(k);
			
			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "check" || constraints.Stereotype == "index")
			{
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					constraint_commands+= "," +"\n";
									
						constraint_commands += "Constraint `"+constraints.Name+"` primary key (" ; 	
					
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					constraint_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						constraint_commands += "foreign key (";
					else 
						constraint_commands +=  "Constraint `"+constraints.Name+"` foreign key (" ; 
				}
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					constraint_commands += "," +"\n";
					if(constraints.Name == "")						
						constraint_commands += "unique (";
					else
						constraint_commands +=  "Constraint `"+constraints.Name+"` unique (" ; 
				}
				else if(constraints.Stereotype == "index") // if the constraints was index
				{
					index_command += "Create Index `"+constraints.Name+"` on Table ";
					
					if(fq_target_tableName != null && fq_target_tableName.Value != "")
					{
						var fq_target_tableName as EA.TaggedValue; 
							fq_target_tableName = constraints.TaggedValues.GetByName("Target Table schema");
						if(fq_target_tableName.Value.endsWith("."))
							index_command += fq_target_tableName.Value;
						else
							index_command += "`"+fq_target_tableName.Value+"`.";
					}
					index_command += table_ELement.Name+" (" ;
				}
				else if(constraints.Stereotype == "check") // if the constraints was check
				{
					constraint_commands += "," +"\n";
					
					if(constraints.Name == "")	
						constraint_commands += "Check (";
					else
						constraint_commands +=  "Constraint `"+constraints.Name+"` Check (";
					
					if(constraints.Code != "")
						constraint_commands += constraints.Code ;
					
				}
				
				
				for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
				{
					constraints_value = constraints.Parameters.GetAt(l);
					if(l>0)
					{
						if(index_command != "" && constraints.Stereotype == "index")
							index_command += ",";
						else
							constraint_commands += ','; 
					} 	
					
					if(index_command != "" && constraints.Stereotype == "index")
						index_command += constraints_value.Name;					
					else
						constraint_commands+= constraints_value.Name;	
				}
				
				if(index_command != "" && constraints.Stereotype == "index")
				{
					index_command += ")\n";		
					
					var index_type as EA.TaggedValue;
					index_type = constraints.TaggedValues.GetByName("Index Type");
					
					if(index_type != null && index_type.Value != "")
						index_command += "As "+index_type.Value+"\n";
					
					var deferred_rebuild as EA.TaggedValue;
					deferred_rebuild = constraints.TaggedValues.GetByName("Deferred Rebuild");
					
					if(deferred_rebuild != null && deferred_rebuild.Value == "True")
						index_command += "With Deferred Rebuild \n";
					
					var index_properties as EA.TaggedValue;
					index_properties = constraints.TaggedValues.GetByName("Index Properties");
					
					if(index_properties != null && index_properties.Notes != "")
						index_command += "Idxproperties ("+index_properties.Notes+")\n";
					
					var index_table as EA.TaggedValue;
					index_table = constraints.TaggedValues.GetByName("Index Table");
					
					if(index_table != null && index_table.Value != "")
						index_command += "In Table "+index_table.Value+"\n";
					
					var row_format as EA.TaggedValue;
					row_format = constraints.TaggedValues.GetByName("Row Format");
					
					if(row_format != null && row_format.Notes != "" )
						index_command += "Row Format "+row_format.Notes+" \n"; 
					
					var stored_as as EA.TaggedValue;
					stored_as = constraints.TaggedValues.GetByName("Stored As");
					
					if(stored_as != null && stored_as.Value != "" )
					{
						if( stored_as.Value == "Format Option")
						{
							var input_format as EA.TaggedValue;
							input_format = constraints.TaggedValues.GetByName("Input Format");
							
							var output_format as EA.TaggedValue;
							output_format = constraints.TaggedValues.GetByName("Output Format");
							
							if(input_format != null && input_format.Value != "")
								index_command += "Stored As "+"INPUTFORMAT "+input_format.Value+" \n"; 
							
							if(output_format != null && output_format.Value != "")
								index_command += "OUTPUTFORMAT "+output_format.Value+" \n"; 
						}
						else
						{
							index_command += "Stored As "+stored_as.Value+" \n"; 
						}
					}
					
					var stored_by as EA.TaggedValue;
					stored_by = constraints.TaggedValues.GetByName("Stored By");
					
					if(stored_by != null && stored_by.Value != "" )
						index_command += "Stored By "+stored_by.Value+" \n"; 
					
					var withSerde as EA.TaggedValue;
					withSerde = constraints.TaggedValues.GetByName("With SerdeProperties");		
					
					if(withSerde != null && withSerde.Notes != "")			
						index_command += "With SerdeProperties ("+ withSerde.Notes + ")\n"; 
					
					var location as EA.TaggedValue;
					location = constraints.TaggedValues.GetByName("Location");
		
					if(location != null && location.Value != "")
						index_command += "Location "+location.Value+"\n";
					
					var tbl_properties as EA.TaggedValue;
					tbl_properties = constraints.TaggedValues.GetByName("Table Properties");		
		
					if(tbl_properties != null && tbl_properties.Notes != "")			
						index_command += "TblProperties ("+ tbl_properties.Notes + ")\n"; 
					
					var index_comment as EA.TaggedValue;
					index_comment = constraints.TaggedValues.GetByName("Index Comment");		
					
					if(index_comment != null && index_comment.Value != "")
						index_command += "Comment "+index_comment.Value+"\n";
					
					
					index_command += ";";
					
					
				}					
				else
				{
					if(constraints.FQStereotype == "Hadoop::FK")
						constraint_commands += ") ";
					else
						constraint_commands += ") disable ";
				}
				
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "Hadoop::FK" connector
				{
					for(var f=0 ; f<table_ELement.Connectors.Count ; f++)
					{
						fk_connector = table_ELement.Connectors.GetAt(f);

						if(fk_connector.FQStereotype == "Hadoop::FK" && fk_connector.ClientEnd.Role == constraints.Name)
						{
							var col_ref as EA.Method;
							
							reference_table = Repository.GetElementByID(fk_connector.SupplierID);

							constraint_commands += "References ";
							var fq_target_tableName as EA.TaggedValue; 
								fq_target_tableName = constraints.TaggedValues.GetByName("Target Table schema");
							if(fq_target_tableName.Value!="" && fq_target_tableName!=null)
							{ 
								if(fq_target_tableName.Value.endsWith("."))
									constraint_commands += fq_target_tableName.Value;
								else
									constraint_commands += "`"+fq_target_tableName.Value+"`.";
							}
							
							constraint_commands +=reference_table.Name+" ";
							
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
									
									ref_column_names += constraints_value.Name;
								}

								constraint_commands += "("+ref_column_names+")";
								constraint_commands += " disable" ;
							}
						}	
					}
				}				
			}
		}
		
		commands[0] = constraint_commands;
		commands[1] = index_command;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return commands;
}

function table_Properties(table_ELement)
{
	var source_commands="";
	try
	{
		// To include additional commands from the "Hadoop::table" Tagged values in source_commands
		
		var table_comment as EA.TaggedValue;
			table_comment = table_ELement.TaggedValues.GetByName("Table Comment");
		
		if(table_comment != null && table_comment.Notes != "")
			source_commands += "Comment "+table_comment.Notes+"\n";
		
		var partition_by as EA.TaggedValue;
		partition_by = table_ELement.TaggedValues.GetByName("Partitioned By");
		
		if(partition_by != null && partition_by.Notes != "" )
			source_commands += "Partitioned By ( "+partition_by.Notes+" )\n"; 
		
		var clustered_by as EA.TaggedValue;
		clustered_by = table_ELement.TaggedValues.GetByName("Clustered By");
		
		if(clustered_by != null && clustered_by.Value != "" )
			source_commands += "Clustered By ( "+clustered_by.Value+" )\n"; 
		
		var sorted_by as EA.TaggedValue;
		sorted_by = table_ELement.TaggedValues.GetByName("Sorted By");
		
		if(sorted_by != null && sorted_by.Value != "" )
			source_commands += "Sorted By ( "+sorted_by.Value+" )\n"; 
		
		var bucket_number as EA.TaggedValue;
		bucket_number = table_ELement.TaggedValues.GetByName("Number of Buckets");
		
		if(bucket_number != null && bucket_number.Value != "" )
			source_commands += "Into "+bucket_number.Value+" Buckets\n"; 
		
		var skewed_by as EA.TaggedValue;
		skewed_by = table_ELement.TaggedValues.GetByName("Skewed By");
		
		if(skewed_by != null && skewed_by.Value != "" )
			source_commands += "Skewed By ( "+skewed_by.Value+" )\n"; 
		
		var skewed_data as EA.TaggedValue;
		skewed_data = table_ELement.TaggedValues.GetByName("Skewed data definition");
		
		if(skewed_data != null && skewed_data.Value != "" )
			source_commands += "On ( "+skewed_data.Value+" )\n"; 
		
		var stored_as_directories as EA.TaggedValue;
		stored_as_directories = table_ELement.TaggedValues.GetByName("Stored As Directories");
		
		if(stored_as_directories != null && stored_as_directories.Value == "True" )
			source_commands += "[Stored As Directories] \n"; 
		
		var row_format as EA.TaggedValue;
		row_format = table_ELement.TaggedValues.GetByName("Row Format");
		
		if(row_format != null && row_format.Notes != "" )
			source_commands += "Row Format "+row_format.Notes+" \n"; 
		
		var stored_as as EA.TaggedValue;
		stored_as = table_ELement.TaggedValues.GetByName("Stored As");
		
		if(stored_as != null && stored_as.Value != "")
		{
			if(stored_as.Value == "Format Options")
			{
				var input_format as EA.TaggedValue;
				input_format = table_ELement.TaggedValues.GetByName("Input Format");
				
				var output_format as EA.TaggedValue;
				output_format = table_ELement.TaggedValues.GetByName("Output Format");
				
				if(input_format != null && input_format.Value != "")
					source_commands += "Stored As INPUTFORMAT "+input_format.Value+" \n"; 
				
				if(output_format != null && output_format.Value != "")
					source_commands += "OUTPUTFORMAT "+output_format.Value+" \n"; 
			}
			else 
			{
				source_commands += "Stored As "+stored_as.Value+" \n"; 
			}
		}
		
		
		var stored_by as EA.TaggedValue;
		stored_by = table_ELement.TaggedValues.GetByName("Stored By");
		
		if(stored_by != null && stored_by.Value != "" )
			source_commands += "Stored By "+stored_by.Value+" \n"; 
		
		var withSerde as EA.TaggedValue;
		withSerde = table_ELement.TaggedValues.GetByName("With SerdeProperties");		
		
		if(withSerde != null && withSerde.Notes != "")			
			source_commands += "With SerdeProperties ("+ withSerde.Notes + ")\n"; 
		
		source_commands += create_Like_Table_command(table_ELement);
		
		var location as EA.TaggedValue;
		location = table_ELement.TaggedValues.GetByName("Location");
		
		if(location != null && location.Value != "")
			source_commands += "Location "+location.Value+"\n";
		
		var tbl_properties as EA.TaggedValue;
		tbl_properties = table_ELement.TaggedValues.GetByName("Table Properties");		
		
		if(tbl_properties != null && tbl_properties.Notes != "")			
			source_commands += "TblProperties ("+ tbl_properties.Notes + ")\n"; 
		
		var select_query as EA.TaggedValue;
		select_query = table_ELement.TaggedValues.GetByName("Select Query");		
		
		if(select_query != null && select_query.Notes != "")			
			source_commands += "As "+ select_query.Notes;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
	return source_commands;
}
function create_Like_Table_command(table_ELement)
{
	var source_commands="";
	try
	{
		var table_con as EA.Connector;
		var connected_table as EA.Element;
		
		for(var l=0 ; l<table_ELement.Connectors.Count; l++)  // To include the Like table command from the Connectors list
		{
			table_con = table_ELement.Connectors.GetAt(l);
			
			var target_fqname as EA.TaggedValue;	
			
			if(table_ELement.ElementID == table_con.ClientID)
			{
				connected_table = Repository.GetElementByID(table_con.SupplierID);	
					
				if(table_con.FQStereotype == "Hadoop::like")
				{					
					source_commands += "Like ";
				
					var fq_target_tableName as EA.TaggedValue; 
						fq_target_tableName = connected_table.TaggedValues.GetByName("Target Table schema");
					if(fq_target_tableName!=null && fq_target_tableName.Value!="")
					{
						if(fq_target_tableName.Value.endsWith("."))
							source_commands += fq_target_tableName.Value;
						else
							source_commands += "`"+fq_target_tableName.Value+"`.";
					}
					
					source_commands += "`"+connected_table.Name + "`\n";
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

function create_view_commands(view_Elements)
{
	var view_commands="";
	try
	{
		var view_type as EA.TaggedValue;
		view_type = view_Elements.TaggedValues.GetByName("View Type"); // To get View Type tag from MDG to initiate the Create view Command
		
		if(view_type != null && view_type.Value == "Materialized")		
			view_commands = "Create Materialized View ";		
		else 
			view_commands = "Create View "; // To write the Create view Command if View type is none or others 
		
		var not_exist as EA.TaggedValue;  // To check if the view element have Not Exist property
		not_exist = view_Elements.TaggedValues.GetByName("Not Exist");
		
		if(not_exist != null &&  not_exist.Value == "True")
			view_commands += "If Not Exists ";
		
			var fq_tableName as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
			fq_tableName = view_Elements.TaggedValues.GetByName("Schema and Database");
			
			if(fq_tableName != null && fq_tableName.Value != "")
			{
				
				if(fq_tableName.Value.endsWith("."))
					view_commands += fq_tableName.Value;
				else
					view_commands += "`"+fq_tableName.Value+"`.";
			}
		
		view_commands += view_Elements.Name +"\n";	
		
		// To include additional commands from the "BigQuery::view" Tagged values in view_commands
		
		var disable_rewrite as EA.TaggedValue;  
		disable_rewrite = view_Elements.TaggedValues.GetByName("Disable Rewrite");
		
		if(disable_rewrite != null &&  disable_rewrite.Value == "True")
			view_commands += "Disable Rewrite \n";
		
		var view_columns as EA.TaggedValue;
		view_columns = view_Elements.TaggedValues.GetByName("View Columns");
		
		if(view_columns != null && view_columns.Notes != "")
			view_commands += "(\n" + view_columns.Notes+"\n)\n";		
		
		var view_comment as EA.TaggedValue;
		view_comment = view_Elements.TaggedValues.GetByName("View Comment");
		
		if(view_comment != null && view_comment.Notes != "")
			view_commands += "Comment" +view_comment.Notes+"\n";
		
		var partition_on as EA.TaggedValue;
		partition_on = view_Elements.TaggedValues.GetByName("Partitioned On");
		
		if(partition_on != null && partition_on.Notes != "" )
			view_commands += "Partitioned On ( "+partition_on.Notes+" )\n"; 
		
		var clustered_on as EA.TaggedValue;
		clustered_on = view_Elements.TaggedValues.GetByName("Clustered On");
		
		if(clustered_on != null && clustered_on.Notes != "" )
			view_commands += "Clustered On ( "+clustered_on.Notes+" )\n"; 
		
		var distributed_on as EA.TaggedValue;
		distributed_on = view_Elements.TaggedValues.GetByName("Distributed On");
		
		if(distributed_on != null && distributed_on.Notes != "" )
			view_commands += "Distributed On ( "+distributed_on.Notes+" )\n"; 
		
		var sorted_on as EA.TaggedValue;
		sorted_on = view_Elements.TaggedValues.GetByName("Sorted On");
		
		if(sorted_on != null && sorted_on.Notes != "" )
			view_commands += "Sorted On ( "+sorted_on.Notes+" )\n"; 
		
		var row_format as EA.TaggedValue;
		row_format = view_Elements.TaggedValues.GetByName("Row Format");
		
		if(row_format != null && row_format.Notes != "" )
			view_commands += "Row Format "+row_format.Notes+" \n";
		
		var stored_as as EA.TaggedValue;
			stored_as = view_Elements.TaggedValues.GetByName("Stored As");
		
		if(stored_as != null && stored_as.Value != "" )
		{
			if( stored_as.Value == "Format Options")
			{
				var input_format as EA.TaggedValue;
				input_format = view_Elements.TaggedValues.GetByName("Input Format");
				
				var output_format as EA.TaggedValue;
				output_format = view_Elements.TaggedValues.GetByName("Output Format");
				
				if(input_format != null && input_format.Value != "")
					view_commands += "Stored As INPUTFORMAT "+input_format.Value+" \n"; 
				
				if(output_format != null && output_format.Value != "")
					view_commands += "OUTPUTFORMAT "+output_format.Value+" \n"; 
				
			}
			else
			{
				view_commands += "Stored As "+stored_as.Value+" \n";  
			}
		}
		
		var stored_by as EA.TaggedValue;
		stored_by = view_Elements.TaggedValues.GetByName("Stored By");
		
		if(stored_by != null && stored_by.Value != "" )
			view_commands += "Stored By "+stored_by.Value+" \n"; 
		
		var withSerde as EA.TaggedValue;
		withSerde = view_Elements.TaggedValues.GetByName("With SerdeProperties");		
		
		if(withSerde != null && withSerde.Notes != "")			
			view_commands += "With SerdeProperties ("+ withSerde.Notes + ")\n"; 
		
		var location as EA.TaggedValue;
		location = view_Elements.TaggedValues.GetByName("Location");
		
		if(location != null && location.Value != "")
			view_commands += "Location "+location.Value+"\n";
		
		var tbl_properties as EA.TaggedValue;
		tbl_properties = view_Elements.TaggedValues.GetByName("Table Properties");		
		
		if(tbl_properties != null && tbl_properties.Notes != "")			
			view_commands += "TblProperties ("+ tbl_properties.Notes + ")\n"; 
		
		var view_def as EA.TaggedValue;
		view_def = view_Elements.TaggedValues.GetByName("viewdef");		
		
		if(view_def != null && view_def.Notes != "")			
			view_commands += "As "+ view_def.Notes;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return view_commands;
}

function create_function_commands(func_Element)
{
	var func_commands="";
	try
	{
		var func_type as EA.TaggedValue;
		func_type = func_Element.TaggedValues.GetByName("Function Type");
		
		if(func_type != null && func_type.Value == "Temporary")
			func_commands = "Create Temporary Function ";
		else
			func_commands = "Create Function ";
		
		var fq_tableName as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
			fq_tableName = func_Element.TaggedValues.GetByName("Schema and Database");
			
			if(fq_tableName != null && fq_tableName.Value != "")
			{
				
				if(fq_tableName.Value.endsWith("."))
					func_commands += fq_tableName.Value;
				else
					func_commands += "`"+fq_tableName.Value+"`.";
			}
		
		func_commands += func_Element.Name +"\n";
		
		// To include additional commands from the "Hadoop::function" Tagged values in source_commands
		
		var class_name as EA.TaggedValue;
		class_name = func_Element.TaggedValues.GetByName("Class Name");
		
		if(class_name != null && class_name.Value != "")
			func_commands += "As "+class_name.Value+ "\n";
		
		var func_value as EA.TaggedValue;
		func_value = func_Element.TaggedValues.GetByName("Function values");
		
		if(func_value != null && func_value.Notes != "")
			func_commands += func_value.Notes+ "\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return func_commands;
}
!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for DB2 database only
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
	
	if(ddl_Element.FQStereotype == "DB2::table") // if the given element was table 
	{
		var table_commands = getTableElements(ddl_Element,columns,constraints,constraints_value,fk_connector,reference_table); // method for get table elements and its properties
		
		source_commands = table_commands[0];
		index = table_commands[1];
		trigger = table_commands[2];		
	}
	else if(ddl_Element.FQStereotype == "DB2::view")
		source_commands = getViewElements(ddl_Element);		// to get the View Elements and its properties
	else if(ddl_Element.FQStereotype == "DB2::sequence") 
		source_commands = getSequenceElements(ddl_Element); // to get the View Elements and its properties
	else if(ddl_Element.FQStereotype == "DB2::function" )
		source_commands = getFunctionElements(ddl_Element); //to get the function Elements and its properties 		
	else if(ddl_Element.FQStereotype == "DB2::procedure")
		source_commands = getProcedureElements(ddl_Element); //to get the procedure Elements and its properties 
	
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
	var source_commands = "" ;
	var index = "" ;
	var trigger = "" ;
	
	try
	{
		source_commands = "Create ";
		
		var table_type as EA.TaggedValue;
		table_type = ddl_Element.TaggedValues.GetByName("Table Type");
		
		if(table_type != null && table_type.Value == "External")		
			source_commands += getExternalTableProperties(ddl_Element,columns);	 // method for get External table elements and its properties
		else if(table_type != null && table_type.Value == "Global Temporary" )
			source_commands += getGlobalTempTable(columns,ddl_Element);		// method for get Global table elements and its properties
		else
		{					
			source_commands += "Table ";	
			
			var not_exists as EA.TaggedValue;
			not_exists = ddl_Element.TaggedValues.GetByName("Not Exists");
			
			if(not_exists != null && not_exists.Value == "True")
				source_commands += "If Not Exists ";
			
			var database_schema as EA.TaggedValue;
			database_schema = ddl_Element.TaggedValues.GetByName("Database and Schema");
			
			if(database_schema != null && database_schema.Value != "")
			{	
				if(	database_schema.Value.endsWith("."))					
					source_commands += database_schema.Value ;
				else
				{
					source_commands += database_schema.Value +". ";
				}
			}
			
			var nameval=namecheck(ddl_Element.Name);
			if(nameval>1)
				source_commands += "\""+ddl_Element.Name + "\" \n";	
			else
				source_commands += ddl_Element.Name + " \n";				
			
			var type_name as EA.TaggedValue;
			type_name = ddl_Element.TaggedValues.GetByName("Type Name");
			
			if(type_name != null && type_name.Value != "")
			{
				source_commands +=  "Of "+ type_name.Value + " \n" ;
				
				var hierarchy_name as EA.TaggedValue;
				hierarchy_name = ddl_Element.TaggedValues.GetByName("Hierarchy Name");
				
				if(hierarchy_name != null && hierarchy_name.Value != "")
					source_commands += "Hierarchy " +hierarchy_name.Value+ "\n" ;
				
				var super_table_name as EA.TaggedValue;
				super_table_name = ddl_Element.TaggedValues.GetByName("Super Table Name");
				
				if(super_table_name != null && super_table_name.Value != "")
					source_commands += "Under "+super_table_name.Value+" Inherit Select Privileges \n"  ;
			}
								
			
			if(ddl_Element.Attributes.Count != 0 || ddl_Element.Methods.Count != 0)
				source_commands += "("  + "\n" ;
			
			source_commands += column_defnition(columns,ddl_Element); // to get the columns and its properties
			
			var constraint_values = [];
			constraint_values = constraint_definition(ddl_Element,constraints,constraints_value,fk_connector,reference_table);			
				
			source_commands += constraint_values[0];		
			index =  constraint_values[1]; 
			trigger = constraint_values[2];				
			
			if(ddl_Element.Attributes.Count != 0 ||  ddl_Element.Methods.Count != 0)
				source_commands +=  "\n)\n"   ;	
			
			source_commands += connectordefinition(ddl_Element); // to get connectors and its properties

			source_commands += getGeneralTableProperties(ddl_Element); // to get table additional properties
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [source_commands,index,trigger];
}

function getExternalTableProperties(ddl_Element,columns)
{
	var source_commands = "" ;
	
	try
	{
		source_commands += "External Table " ;
		
		var database_schema as EA.TaggedValue;
		database_schema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(database_schema != null && database_schema.Value != "")
		{	
			if(	database_schema.Value.endsWith("."))					
				source_commands += database_schema.Value  ;
			else
				source_commands += database_schema.Value + ".";
		}
		if(ddl_Element.Name!="")
		{
			var nameval=namecheck(ddl_Element.Name);
			if(nameval>1)
				source_commands += "\""+ddl_Element.Name + "\" \n";	
			else
				source_commands += ddl_Element.Name + " \n";
		}
		
		var external_file as EA.TaggedValue;
		external_file = ddl_Element.TaggedValues.GetByName("External File");

		if(external_file != null && external_file.Value != "")
			source_commands += external_file.Value  + "\n";

		if(ddl_Element.Attributes.Count != 0 || ddl_Element.Methods.Count != 0)
			source_commands += "( \n" ;

		source_commands += column_defnition(columns,ddl_Element); // To get the column and its properties		

		if(ddl_Element.Attributes.Count != 0 ||  ddl_Element.Methods.Count != 0)
			source_commands +=  "\n)\n"   ;	

		source_commands += connectordefinition(ddl_Element); // To get the like connectors and its properties	

		var table_option as EA.TaggedValue;
		table_option = ddl_Element.TaggedValues.GetByName("Table Options");

		if(table_option != null && table_option.Notes != "")
			source_commands += "Using ( " +table_option.Notes+ " )\n";

		var select_query as EA.TaggedValue;
		select_query = ddl_Element.TaggedValues.GetByName("Select Query");

		if(select_query != null && select_query.Notes != "")
			source_commands += "As "+select_query.Notes+" \n";	
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	
	return source_commands;
	
}

function getGlobalTempTable(columns,ddl_Element)
{
	var source_commands = "";
	
	try
	{
		source_commands += "Global Temporary Table ";
		
		var database_schema as EA.TaggedValue;
		database_schema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(database_schema != null && database_schema.Value != "")
		{	
			if(	database_schema.Value.endsWith("."))					
				source_commands += database_schema.Value ;
			else
				source_commands += database_schema.Value + ".";
		}
			var nameval=namecheck(ddl_Element.Name);
			if(nameval>1)
				source_commands += "\""+ddl_Element.Name + "\" \n";	
			else
				source_commands += ddl_Element.Name + " \n";	

		if(ddl_Element.Attributes.Count != 0 || ddl_Element.Methods.Count != 0)
			source_commands += "("  + "\n" ;
		
		source_commands += column_defnition(columns,ddl_Element); // To get the column and its properties		
		
		if(ddl_Element.Attributes.Count != 0 ||  ddl_Element.Methods.Count != 0)
			source_commands +=  "\n)\n"   ;	
		
		source_commands += connectordefinition(ddl_Element);  // To get the like connectors and its properties	
		
		var select_query as EA.TaggedValue;
		select_query = ddl_Element.TaggedValues.GetByName("Select Query");
		
		if(select_query != null && select_query.Notes != "")
			source_commands += "As ( "+select_query.Notes+" )\n";
		
		var query_populate as EA.TaggedValue;
		query_populate = ddl_Element.TaggedValues.GetByName("Query Populate");
		
		if(query_populate != null)
		{
			if(query_populate.Value == "Yes")
				source_commands += "With Data \n";
			else if(query_populate.Value == "No")
				source_commands += "With No Data \n";
		}
		
		var table_preservation as EA.TaggedValue;
		table_preservation = ddl_Element.TaggedValues.GetByName("Table Preservation");
		
		if(table_preservation != null && table_preservation.Value != "<none>" && table_preservation.Value != "")
			source_commands += "On Commit "+table_preservation.Value+" Rows \n";
		
		var table_log as EA.TaggedValue;
		table_log = ddl_Element.TaggedValues.GetByName("Table Log");
		
		if(table_log != null)
		{
			if(table_log.Value == "Yes")
				source_commands += "Logged \n";
			else if(table_log.Value == "No")
			{
				source_commands += "Not Logged \n";
				
				var roll_back as EA.TaggedValue;
				roll_back = ddl_Element.TaggedValues.GetByName("Rollback Row");
				
				if(roll_back != null && roll_back.Value == "True")
					source_commands += "On Rollback Delete Rows \n";					
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

function getGeneralTableProperties(ddl_Element)
{
	var source_commands = "";
	
	try
	{
			var select_query as EA.TaggedValue;
			select_query = ddl_Element.TaggedValues.GetByName("Select Query");
			
			if(select_query != null && select_query.Notes != "")
				source_commands += "As ( "+select_query.Notes+" )\n";
			
			var query_populate as EA.TaggedValue;
			query_populate = ddl_Element.TaggedValues.GetByName("Query Populate");
			
			if(query_populate != null)
			{
				if(query_populate.Value == "Yes")
					source_commands += "With Data \n";
				else if(query_populate.Value == "No")
					source_commands += "With No Data \n";
			}
			
			var default_option as EA.TaggedValue;
			default_option = ddl_Element.TaggedValues.GetByName("Default Option");
			
			if(default_option != null && default_option.Value != "" && default_option.Value != "<none>")
				source_commands += default_option.Value + " Column Defaults " + "\n";
			
			var identity_option as EA.TaggedValue;
			identity_option = ddl_Element.TaggedValues.GetByName("Identity Option");
			
			if(identity_option != null && identity_option.Value != "<none>" && identity_option.Value != "")
				source_commands += identity_option.Value + " Identity \n" ;
			
			var column_attribute as EA.TaggedValue;
			column_attribute = ddl_Element.TaggedValues.GetByName("Column Attribute");
			
			if(column_attribute != null && column_attribute.Value == "True")
				source_commands += "Column Attribute \n";
			
			var refresh_option as EA.TaggedValue;
			refresh_option = ddl_Element.TaggedValues.GetByName("Refresh Option");
			
			if(refresh_option != null && refresh_option.Value != "" && refresh_option.Value != "<none>")
				source_commands += "Data Initially Deferred Refresh " +refresh_option.Value+ " \n";
			
			var query_optimization as EA.TaggedValue;
			query_optimization = ddl_Element.TaggedValues.GetByName("Query Optimization");
			
			if(query_optimization != null && query_optimization.Value != "" && query_optimization.Value == "<none>")
				source_commands += query_optimization + " Query Optimization \n";
			
			var maintained_by as EA.TaggedValue;
			maintained_by = ddl_Element.TaggedValues.GetByName("Maintained By");
			
			if(maintained_by != null)
			{
				if(maintained_by.Value == "System")
					source_commands += "Maintained By System \n" ;
				else if(maintained_by.Value == "User")
					source_commands += "Maintained By User \n" ;
				else if(maintained_by.Value == "Replication")
					source_commands += "Maintained By Replication \n" ;
				else if(maintained_by.Value == "Federated Tool")
					source_commands += "Maintained By Federated_Tool \n" ;			
			}
			
			var stagging_for as EA.TaggedValue;
			stagging_for = ddl_Element.TaggedValues.GetByName("Staging For");
			
			if(stagging_for != null && stagging_for.Value != "")
				source_commands += "For "+stagging_for.Value+" Propagate Immediate";
			
			var organize_by as EA.TaggedValue;
			organize_by = ddl_Element.TaggedValues.GetByName("Organize By");
			
			if(organize_by != null && organize_by.Notes != "")
				source_commands += "Organize By "+organize_by.Notes+" \n" ;
			
			var data_capture as EA.TaggedValue;
			data_capture = ddl_Element.TaggedValues.GetByName("Data Capture");
			
			if(data_capture != null)
			{
				if(data_capture.Value == "None")
					source_commands += "Data Capture None \n";
				else if(data_capture.Value == "Change")
					source_commands += "Data Capture Changes \n";			
			}
			
			var tablespace_clause as EA.TaggedValue;
			tablespace_clause = ddl_Element.TaggedValues.GetByName("Tablespace Clause");
			
			if(tablespace_clause != null && tablespace_clause.Notes != "")
				source_commands += tablespace_clause.Notes + " \n";
			
			var distibute_by as EA.TaggedValue;
			distibute_by = ddl_Element.TaggedValues.GetByName("Distribute By");
			
			if(distibute_by != null && distibute_by.Notes != "")
				source_commands += "Distribute By "+distibute_by.Notes+" \n" ;
			
			var partition_by as EA.TaggedValue;
			partition_by = ddl_Element.TaggedValues.GetByName("Partition By");
			
			if(partition_by != null && partition_by.Notes != "")
				source_commands += "Partition By "+partition_by.Notes+" \n" ;
			
			var compress as EA.TaggedValue;
			compress = ddl_Element.TaggedValues.GetByName("Compress");
			
			if(compress != null)
			{
				if(compress.Value == "Yes")
				{
					source_commands += "Compress Yes \n" ;
					
					var compression_level as EA.TaggedValue;
					compression_level = ddl_Element.TaggedValues.GetByName("Compression Level");
					
					if(compression_level != null &&  compression_level.Value != "" && compression_level.Value != "<none>")
						source_commands += compression_level.Value + "\n";				
				}
				else if(compress.Value == "No")
					source_commands += "Compress No \n";		
				
			}
			
			var value_compression as EA.TaggedValue;
			value_compression = ddl_Element.TaggedValues.GetByName("Value Compression");
			
			if(value_compression != null && value_compression.Value == "True")
				source_commands += "Value Compression \n";
			
			var not_dropped as EA.TaggedValue;
			not_dropped = ddl_Element.TaggedValues.GetByName("Not Dropped");
			
			if(not_dropped != null && not_dropped.Value == "True")
				source_commands += "With Restrict On Drop \n";
			
			var no_logged_initially as EA.TaggedValue;
			no_logged_initially = ddl_Element.TaggedValues.GetByName("Not Logged Initially");
			
			if(no_logged_initially != null && no_logged_initially.Value == "True")
				source_commands +=  "Not Logged Initially \n";
			
			var encoding_schema as EA.TaggedValue;
			encoding_schema = ddl_Element.TaggedValues.GetByName("Encoding Schema");
			
			if(encoding_schema != null && encoding_schema.Value != "" && encoding_schema.Value != "<none>")
				source_commands += "CCSID "+encoding_schema.Value+" \n";
			
			var security_policy as EA.TaggedValue;
			security_policy = ddl_Element.TaggedValues.GetByName("Security Policy");
			
			if(security_policy != null && security_policy.Value != "")
				source_commands += "Security Policy "+security_policy.Value+" \n";
			
			var table_options as EA.TaggedValue;
			table_options = ddl_Element.TaggedValues.GetByName("Table Options");
			
			if(table_options != null && table_options.Notes != "")
				source_commands +=  "Options ("+table_options.Notes+" )\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands ;	
}

function connectordefinition(ddl_Element)
{
	var source_commands = "";
	var table_con as EA.Connector;
	var connected_table as EA.Element;
	
	try
	{
		for(var l=0 ; l<ddl_Element.Connectors.Count; l++)  // To include the Like table command from the Connectors list
		{
			table_con = ddl_Element.Connectors.GetAt(l);

			if(ddl_Element.ElementID == table_con.ClientID)
			{
				connected_table = Repository.GetElementByID(table_con.SupplierID);	

				if(table_con.FQStereotype == "DB2::like")	
				{
					source_commands += "Like ";
					
					var target_tbl_schema as EA.TaggedValue;
					target_tbl_schema = table_con.TaggedValues.GetByName("Database and Schema");
					
					if(target_tbl_schema != null && target_tbl_schema.Value != "")
					{	
						if(	target_tbl_schema.Value.endsWith("."))					
							source_commands += target_tbl_schema.Value ;
						else
							source_commands += target_tbl_schema.Value + ".";
					}
					
					var nameval=namecheck(connected_table.Name);
					if(nameval>1)
						source_commands += "\""+connected_table.Name + "\" \n";	
					else
						source_commands += connected_table.Name + " \n";

					var default_option as EA.TaggedValue;
					default_option = table_con.TaggedValues.GetByName("Default Option");

					if(default_option != null && default_option.Value != "" && default_option.Value != "<none>")
						source_commands += default_option.Value + " Column Defaults " + "\n";

					var identity_option as EA.TaggedValue;
					identity_option = table_con.TaggedValues.GetByName("Identity Option");

					if(identity_option != null && identity_option.Value != "<none>" && identity_option.Value != "")
						source_commands += identity_option.Value + " Identity \n" ;

					var column_attribute as EA.TaggedValue;
					column_attribute = table_con.TaggedValues.GetByName("Column Attribute");

					if(column_attribute != null && column_attribute.Value == "True")
						source_commands += "Column Attribute \n";
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

function column_defnition(columns,ddl_Element)
{
	var source_commands = "";
	
	try
	{
		for(var j=0 ; j<ddl_Element.Attributes.Count ; j++)
		{
			columns = ddl_Element.Attributes.GetAt(j);
			
			var oid_column as EA.TaggedValue;
			oid_column = columns.TaggedValues.GetByName("OID Column");
			
			if(oid_column != null && oid_column.Value == "True")
				source_commands += "Ref Is ";
			
			var nameval=namecheck(columns.Name);
			if(nameval>1)
				source_commands += "\""+columns.Name + "\" " + columns.Type+" ";
			else
				source_commands += "\""+columns.Name + "\" " + columns.Type+" "
					
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
			
			var char_encode as EA.TaggedValue;
			char_encode = columns.TaggedValues.GetByName("Charater Encoding");
			
			if(char_encode != null && char_encode.Value != "")
				source_commands += char_encode.Value;

			
			if(oid_column != null && oid_column.Value == "True")
				source_commands += "User Generated ";
			
			var with_option as EA.TaggedValue;
			with_option = columns.TaggedValues.GetByName("With Option");
			
			if(with_option != null && with_option.Value == "True")
				source_commands += "With Options ";
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
					
			if (NotNull)
				source_commands += "Not Null ";
			
			var lob_log as EA.TaggedValue;
			lob_log = columns.TaggedValues.GetByName("LOB Log");
			
			if(lob_log != null)
			{
				if(lob_log.Value == "Yes")
					source_commands += "Logged ";
				else if(lob_log.Value == "No")
					source_commands += "Not Logged ";
			}
			
			var lob_compact as EA.TaggedValue;
			lob_compact = columns.TaggedValues.GetByName("LOB Compact");

			if(lob_compact != null)
			{
				if(lob_compact.Value  == "Yes")
					source_commands += "Compact ";
				else if(lob_compact.Value == "No")
					source_commands += "Not Compact ";		
			}
			
			var column_scope as EA.TaggedValue;
			column_scope = columns.TaggedValues.GetByName("Column Scope");
			
			if(column_scope != null && column_scope.Value != "")
				source_commands +=  "Scope "+column_scope.Value+ " ";
			
			if( columns.Default != "")
				source_commands += "DEFAULT "+columns.Default+" ";
			
			var gen_clause as EA.TaggedValue;
			gen_clause = columns.TaggedValues.GetByName("Generated Clause");
			
			if(gen_clause != null && gen_clause.Notes != "")
				source_commands += gen_clause.Notes+" ";
			
			var inline_length as EA.TaggedValue;
			inline_length = columns.TaggedValues.GetByName("Inline Length");
			
			if(inline_length != null && inline_length.Value != "")
				source_commands += "Inline Length "+inline_length.Value+" ";
			
			var compress_system as EA.TaggedValue;
			compress_system = columns.TaggedValues.GetByName("Compress System");
			
			if(compress_system != null && compress_system.Value == "True")
				source_commands += "Compress System Default ";
			
			var secured_with as EA.TaggedValue;
			secured_with = columns.TaggedValues.GetByName("Secured With");
			
			if(secured_with != null && secured_with.Value != "")
				source_commands += "Secured With "+secured_with.Value+" ";
			
			var implicitly_hidden as EA.TaggedValue;
			implicitly_hidden = columns.TaggedValues.GetByName("Implicitly Hidden");
			
			if(implicitly_hidden != null)
			{
				if(implicitly_hidden.Value == "Yes")
					source_commands += "Implicitly Hidden " ;
				else if(implicitly_hidden.Value == "No")
					source_commands += "No Implicitly Hidden " ;
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

function constraint_definition(ddl_Element,constraints,constraints_value,fk_connector,reference_table)
{
	
	var source_commands = "";
	var index  = "";
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
					{
						var nameval=namecheck(constraints.Name);
						if(nameval>1)
							source_commands +=  "Constraint \""+constraints.Name+"\" primary key (" ; 
						else
							source_commands +=  "Constraint "+constraints.Name + " primary key (";
					}
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					if(ddl_Element.Attributes.Count != 0 || K != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						source_commands += "foreign key (";
					else 
					{
						var nameval=namecheck(constraints.Name);
						if(nameval>1)
							source_commands +=  "Constraint \""+constraints.Name+"\" foreign key (" ; 
						else
							source_commands +=  "Constraint "+constraints.Name + " foreign key (";
					}						
				}
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					if(ddl_Element.Attributes.Count != 0 || k != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")						
						source_commands += "unique (";
					else 
					{
						var nameval=namecheck(constraints.Name);
						if(nameval>1)
							source_commands +=  "Constraint \""+constraints.Name+"\" unique (" ; 
						else
							source_commands +=  "Constraint "+constraints.Name + " unique (";
					}
				}
				else if(constraints.Stereotype == "period")
				{
					if(ddl_Element.Attributes.Count != 0 || k != 0)
						source_commands+= "," +"\n";
					
					source_commands+= "Period ";

					var period_type as EA.TaggedValue;
					period_type = constraints.TaggedValues.GetByName("Period Type");
					
					if(period_type != null)
					{
						if(period_type.Value == "System Time")
							source_commands+= "System_Time (";
						else if(period_type.Value == "Business Time")
							source_commands+= "Business_Time (";
					}
				}
				else if(constraints.Stereotype == "check") // if the constraints was check
				{
					if(ddl_Element.Attributes.Count != 0 || k != 0)
						source_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						source_commands += "Check (";
					else
					{
						var nameval=namecheck(constraints.Name);
						if(nameval>1)
							source_commands +=  "Constraint \""+constraints.Name+"\"  Check (" ; 
						else
							source_commands +=  "Constraint "+constraints.Name + "  Check (";
					}
					
					
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
						if(is_unique.Value == "1" || is_unique.Value == "True")
							index += "Unique ";
					}
					
					index += "Index ";
					
					var index_db_schema as EA.TaggedValue;
					index_db_schema = constraints.TaggedValues.GetByName("Database and Schema");
					
					if(index_db_schema != null && index_db_schema.Value != "")
					{	
						if(	index_db_schema.Value.endsWith("."))					
							index += index_db_schema.Value ;
						else
							index += index_db_schema.Value + ".";
					}
					
					var nameval=namecheck(constraints.Name);
						if(nameval>1)
							index +=  "\""+constraints.Name+"\"  On "; 
						else
							index +=  constraints.Name+" On ";
						
					
					
					var target_schema as EA.TaggedValue;
					target_schema = constraints.TaggedValues.GetByName("Target Table schema");
					
					if(target_schema != null && target_schema.Value != "")
					{	
						if(	target_schema.Value.endsWith("."))					
							index += target_schema.Value ;
						else
							index += target_schema.Value + ".";
					}
					
					var nameval=namecheck(ddl_Element.Name);
					if(nameval>1)
						index += "\""+ddl_Element.Name + "\" \n";	
					else
						index += ddl_Element.Name + " \n";	
					
					if(constraints.Parameters.Count != 0)
						index += "( " ;
					
				}		
				else if(constraints.Stereotype == "trigger")
				{
					trigger += "Create ";
					
					var is_replace as EA.TaggedValue;
					is_replace = constraints.TaggedValues.GetByName("Is Replace");
					
					if(is_replace != null && is_replace.Value == "True")
						trigger += "Or Replace ";
					
					trigger += "Trigger ";
					
					var trigger_db_schema as EA.TaggedValue;
					trigger_db_schema = constraints.TaggedValues.GetByName("Database and Schema");
					
					if(trigger_db_schema != null && trigger_db_schema.Value != "")
					{	
						if(	trigger_db_schema.Value.endsWith("."))					
							index += trigger_db_schema.Value ;
						else
							index += trigger_db_schema.Value + ".";
					}
					
					trigger += "\""+constraints.Name+ "\" \n";
					
					var trg_time as EA.TaggedValue;
					trg_time = constraints.TaggedValues.GetByName("TRG_TIME");
					
					if(trg_time != null && trg_time.Value != "" )
						trigger += trg_time.Value + " \n";
					
					var trg_event as EA.TaggedValue;
					trg_event  = constraints.TaggedValues.GetByName("TRG_EVENT");
					
					if(trg_event != null && trg_event.Value != "")
						trg_event_value +=  trg_event.Value +"\n";	
				}
				
				for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
				{
					constraints_value = constraints.Parameters.GetAt(l);				
					
					if(l>0)
					{
						if(index != "" && constraints.Stereotype == "index" )
							index += ",";
						else if(constraints.Stereotype == "trigger")
							trg_constr += ",";						
						else
							source_commands += ","; 
					} 	
					
					if(index != "" && constraints.Stereotype == "index" )
						index += "\""+constraints_value.Name+"\"";
					else if(constraints.Stereotype == "trigger")
							trg_constr += constraints_value.Name ;
					else		
						source_commands+= constraints_value.Name;	
				}
				
				if(index != "" && constraints.Stereotype == "index" )
				{
					if(constraints.Parameters.Count != 0)
						index += ") \n" ;
					
					var partitioned as EA.TaggedValue;
					partitioned = constraints.TaggedValues.GetByName("Partitioned Index");
					
					if(partitioned != null)
					{
						if(partitioned.Value == "Yes" )
							index += "Partitioned \n";
						else if(partitioned.Value == "No")
							index += "Not Partitioned \n";					
					}
					
					var tablespace as EA.TaggedValue;
					tablespace = constraints.TaggedValues.GetByName("Tablespace");
					
					if(tablespace != null && tablespace.Value != "")
						index += "In \""+tablespace.Value+"\"\n";
					
					var spec_only as EA.TaggedValue;
					spec_only = constraints.TaggedValues.GetByName("Specification Only");
					
					if(spec_only != null && spec_only.Value == "True")
						index += "Specification Only \n";
					
					var additional_columns as EA.TaggedValue;
					additional_columns = constraints.TaggedValues.GetByName("additional Columns");
					
					if(additional_columns != null && additional_columns.Notes != "")
						index += "Include ( "+additional_columns.Notes+" )\n";
					
					var xml_specification as EA.TaggedValue;
					xml_specification = constraints.TaggedValues.GetByName("XML Specification");
					
					if(xml_specification != null && xml_specification.Notes != "")
						index +=  xml_specification.Notes + "\n";
					
					var is_clustered as EA.TaggedValue;
					is_clustered = constraints.TaggedValues.GetByName("Clustered");
					
					if(is_clustered != null)
					{
						if(is_clustered.Value == "1" || is_clustered.Value == "True")
							index += "Cluster ";
					}
					
					var pct_free as EA.TaggedValue;
					pct_free = constraints.TaggedValues.GetByName("Percentage Free");
					
					if(pct_free != null && pct_free.Value != "")
						index += "PCTFree "+pct_free.Value+" \n";
					
					var min_percentage as EA.TaggedValue;
					min_percentage =  constraints.TaggedValues.GetByName("Minimum Percentage");
					
					if(min_percentage != null && min_percentage.Value != "")
						index += "MinPCTUsed "+min_percentage.Value+"\n";
					
					var reverse_scan as EA.TaggedValue;
					reverse_scan = constraints.TaggedValues.GetByName("Reverse Scans");
					
					if(reverse_scan != null && reverse_scan.Value != "" && reverse_scan.Value != "<none>")
						index += reverse_scan.Value + " Reverse Scans \n";
					
					var page_split as EA.TaggedValue;
					page_split = constraints.TaggedValues.GetByName("Page Split");

					if(page_split != null && page_split.Value != null && page_split.Value != "")
						index += "Page Split "+page_split.Value+" \n";
					
					var index_statistics as EA.TaggedValue;
					index_statistics = constraints.TaggedValues.GetByName("Index Statistics");
					
					if(index_statistics != null)
					{
						if(index_statistics.Value == "Collected Detailed")
							index += "Collect Detailed Statistics \n";
						else if(index_statistics.Value == "Sample Detailed")
							index += "Collect Sampled Detailed Statistics \n";
						else if(index_statistics.Value == "Unsample Detailed")
							index += "Collect Sampled Detailed Statistics \n";
						else if(index_statistics.Value == "Collected")
							index += "Collect Statistics \n";
					}
					
					var compress as EA.TaggedValue;
					compress = constraints.TaggedValues.GetByName("Compress");
					
					if(compress != null && compress.Value != "" && compress.Value != "<none>")
						index += "Compress "+compress.Value+"\n";
					
					var null_keys as EA.TaggedValue;
					null_keys = constraints.TaggedValues.GetByName("Null Keys");
					
					if(null_keys != null && null_keys.Value != "" && null_keys.Value != "<none>")
						index += null_keys.Value+" Null Keys \n";
					
					var index_extension as EA.TaggedValue;
					index_extension = constraints.TaggedValues.GetByName("Index Extension");
					
					if(index_extension != null && index_extension.Notes != "")
						index += "Extend Using "+index_extension.Notes+"\n";				
					
					index += "; \n\n";
				}
				else if(trigger != "" && constraints.Stereotype == "trigger")
				{
					if(trg_event_value != "")
					{
						if(trg_event_value.includes("Update") && trg_constr !="") 
							trigger += trg_event_value.replace("Update", "Update Of " + trg_constr);							
						else
							trigger += trg_event_value;						
					}
					
					trigger += " On ";
					
					var target_schema as EA.TaggedValue;
					target_schema = constraints.TaggedValues.GetByName("Target Table schema");
					
					if(target_schema != null && target_schema.Value != "")
					{	
						if(	target_schema.Value.endsWith("."))					
							trigger += target_schema.Value ;
						else
							trigger += target_schema.Value + ".";
					}					
					var nameval=namecheck(ddl_Element.Name);
					if(nameval>1)
						source_commands +=  "\""+ddl_Element.Name+ "\"\n"; 
					else
						source_commands +=  ddl_Element.Name+ "\n";
					
					var correlation_names as EA.TaggedValue;
					correlation_names = constraints.TaggedValues.GetByName("Correlation Names");
					
					if(correlation_names != null && correlation_names.Notes != "")
						trigger += "Referencing "+ correlation_names.Notes+"\n";
					
					var for_each as EA.TaggedValue;
					for_each = constraints.TaggedValues.GetByName("For Each");
					
					if(for_each != null && for_each.Value != "" && for_each.Value != "<none>")
						trigger += "For Each "+for_each.Value+"\n";
					
					var secured as EA.TaggedValue;
					secured = constraints.TaggedValues.GetByName("Secured");	
					
					if(secured != null)
					{
						if(secured.Value == "Yes")
							trigger += "Secured \n";
						else if(secured.Value == "No")
							trigger += "Not Secured \n";					
					}
					
					var when_condition as EA.TaggedValue;
					when_condition = constraints.TaggedValues.GetByName("When Condition");
					
					if(when_condition != null && when_condition.Notes != "")
						trigger +=  "When ( "+ when_condition.Notes+" ) \n";
					
					if(constraints.Code != "")
							trigger += constraints.Code + "\n";				
					
					trigger += "; \n\n";
				}
				else		
					source_commands += ") ";	
									
						
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "PostgreSQL::FK" connector
				{
					for(var f=0 ; f<ddl_Element.Connectors.Count ; f++)
					{
						fk_connector = ddl_Element.Connectors.GetAt(f);

						if(fk_connector.FQStereotype == "DB2::FK" && fk_connector.ClientEnd.Role == constraints.Name)
						{
							var col_ref as EA.Method;
							
							reference_table = Repository.GetElementByID(fk_connector.SupplierID);

							source_commands += "References ";
							
							var target_schema as EA.TaggedValue;
							target_schema = constraints.TaggedValues.GetByName("Target Table schema");
							
							if(target_schema != null && target_schema.Value != "")
							{	
								if(	target_schema.Value.endsWith("."))					
									source_commands += target_schema.Value ;
								else
									source_commands += target_schema.Value + ".";
							}	
										
							var nameval=namecheck(reference_table.Name);
								if(nameval>1)
									source_commands+= "\""+reference_table.Name+"\" ";
								else
									source_commands += reference_table.Name + " ";
							
							
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
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [source_commands,index,trigger];	
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
		
		source_commands += "View ";
		
		var database_schema as EA.TaggedValue;
		database_schema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(database_schema != null && database_schema.Value != "")
		{	
			if(	database_schema.Value.endsWith("."))					
				source_commands += database_schema.Value ;
			else
				source_commands += database_schema.Value + ".";
		}		
		
		var nameval=namecheck(ddl_Element.Name);
		if(nameval>1)
			source_commands += "\""+ddl_Element.Name + "\" \n";	
		else
			source_commands += ddl_Element.Name + " \n";
		
		var view_type as EA.TaggedValue;
		view_type = ddl_Element.TaggedValues.GetByName("View Type");
		
		if(view_type != null && view_type.Value == "Root View")
		{
			var type_name as EA.TaggedValue;
			type_name = ddl_Element.TaggedValues.GetByName("Type Name");
		
			if(type_name != null && type_name.Value != "")
				source_commands += "Of " +type_name.Value+ " \n";
			
			var root_view_def as EA.TaggedValue;
			root_view_def = ddl_Element.TaggedValues.GetByName("Root View Definition");
			
			if(root_view_def != null && root_view_def.Notes != "")
				source_commands += "MODE DB2SQL ( " +root_view_def.Notes+ " )\n";
			
						
		}
		else if(view_type != null && view_type.Value == "Sub View")
		{
			var super_view_name as EA.TaggedValue;
			super_view_name = ddl_Element.TaggedValues.GetByName("Super View Name");
			
			if(super_view_name != null && super_view_name.Value != "")
				source_commands += "Mode DB2SQL Under "+super_view_name.Value+" Inherit Select Privileges \n" ;
			
			var is_extend as EA.TaggedValue;
			is_extend =  ddl_Element.TaggedValues.GetByName("Is Extend");
			
			if(is_extend != null && is_extend.Value == "True")
				source_commands += "Extend \n";			
		}
		else
		{
			var view_column as EA.TaggedValue;
			view_column = ddl_Element.TaggedValues.GetByName("View Columns");
		
			if(view_column != null && view_column.Notes != "")
				source_commands += "( " +view_column.Notes+ " )\n";
		}
				
		var view_def as EA.TaggedValue;
		view_def = ddl_Element.TaggedValues.GetByName("viewdef");
		
		if(view_def != null && view_def.Notes != "")
			source_commands += "As "+view_def.Notes+" \n";
		
		var check_option as EA.TaggedValue;
		check_option =  ddl_Element.TaggedValues.GetByName("Check Option");
		
		if(check_option != null && check_option.Value != "<none>" && check_option.Value != "")
			source_commands += "With "+check_option.Value+" Check Option \n";
		
		var row_movement as EA.TaggedValue;
		row_movement = ddl_Element.TaggedValues.GetByName("Row Movement");
		
		if(row_movement != null)
		{
			if(row_movement.Value == "Yes")
				source_commands += "With Row Movement \n";
			else if(row_movement.Value == "No" )
				source_commands += "With No Row Movement \n";			
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
		
		var is_replace as EA.TaggedValue;
		is_replace = ddl_Element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			source_commands += "Or Replace ";

		source_commands += "Sequence ";
		
		var database_schema as EA.TaggedValue;
		database_schema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(database_schema != null && database_schema.Value != "")
		{	
			if(	database_schema.Value.endsWith("."))					
				source_commands += database_schema.Value + " \n";
			else
				source_commands += database_schema.Value +". \n";
		}
		
			var nameval=namecheck(ddl_Element.Name);
			if(nameval>1)
				source_commands += "\""+ddl_Element.Name + "\" \n";	
			else
				source_commands += ddl_Element.Name + " \n";
		
		var data_type as EA.TaggedValue;
		data_type = ddl_Element.TaggedValues.GetByName("Data Type");
		
		if(data_type != null && data_type.Value != "")
			source_commands += "As "+data_type.Value+" \n";
		
		var start_with as EA.TaggedValue;
		start_with = ddl_Element.TaggedValues.GetByName("Start With");
		
		if(start_with != null && start_with.Value != "")
			source_commands += "Start With "+start_with.Value+" \n";
		
		var increment_by as EA.TaggedValue;
		increment_by = ddl_Element.TaggedValues.GetByName("Increment By");
		
		if(increment_by != null && increment_by.Value != "")
			source_commands += "Increment By "+increment_by.Value+" \n";
		
		var min_value_spec as EA.TaggedValue;
		min_value_spec = ddl_Element.TaggedValues.GetByName("MinValue Specification");
		
		if(min_value_spec != null)
		{
			if(min_value_spec.Value == "Yes")
			{
				source_commands += "MinValue ";
				
				var min_value as EA.TaggedValue;
				min_value = ddl_Element.TaggedValues.GetByName("MinValue");
				
				if(min_value != null && min_value.Value != "")
					source_commands += min_value.Value+" \n";		
				
			}
			else if(min_value_spec.Value == "No")
				source_commands += "No MinValue \n";		
			
		}
		
		var max_value_spec as EA.TaggedValue;
		max_value_spec = ddl_Element.TaggedValues.GetByName("MaxValue Specification");
		
		if(max_value_spec != null)
		{
			if(max_value_spec.Value == "Yes")
			{
				source_commands += "MaxValue ";
				
				var max_value as EA.TaggedValue;
				max_value = ddl_Element.TaggedValues.GetByName("MaxValue");
				
				if(max_value != null && max_value.Value != "")
					source_commands += max_value.Value+" \n";		
				
			}
			else if(max_value_spec.Value == "No")
				source_commands += "No MaxValue \n";		
			
		}
		
		var circular_seq as EA.TaggedValue;
		circular_seq = ddl_Element.TaggedValues.GetByName("Circular Sequence");
		
		if(circular_seq != null)
		{
			if(circular_seq.Value == "Yes")
				source_commands += "Cycle \n";
			else if(circular_seq.Value == "No")
				source_commands += "No Cycle \n";			
		}
		
		var cache as EA.TaggedValue;
		cache = ddl_Element.TaggedValues.GetByName("Cache");
		
		if(cache != null)
		{
			if(cache.Value == "Yes")
			{
				source_commands += "Cache ";
				
				var cache_value as EA.TaggedValue;
				cache_value = ddl_Element.TaggedValues.GetByName("Cache Value");
				
				if(cache_value != null && cache_value.Value != "")
					source_commands += cache_value.Value+" \n";		
				
			}
			else if(cache.Value == "No")
				source_commands += "No Cache \n";		
			
		}
		
		var order as EA.TaggedValue;
		order = ddl_Element.TaggedValues.GetByName("Order");
		
		if(order != null)
		{
			if(order.Value == "Yes")
				source_commands += "Order \n";
			else if(order.Value == "No")
				source_commands += "No Order \n";			
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
		source_commands = "Create ";
		
		var is_replace as EA.TaggedValue;
		is_replace = ddl_Element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			source_commands += "Or Replace ";
		
		source_commands += "Function ";
		
		var database_schema as EA.TaggedValue;
		database_schema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(database_schema != null && database_schema.Value != "")
		{	
			if(	database_schema.Value.endsWith("."))					
				source_commands += database_schema.Value ;
			else
				source_commands += database_schema.Value + ".";
		}
		
		var nameval=namecheck(ddl_Element.Name);
		if(nameval>1)
			source_commands += "\""+ddl_Element.Name+"\"\n ( ";	
		else
			source_commands += ddl_Element.Name + " \n (";
					
		var  parameter_declaration as EA.TaggedValue;
		parameter_declaration = ddl_Element.TaggedValues.GetByName("Parameter Declaration");	
		
		if(parameter_declaration != null && parameter_declaration.Notes != "")
			source_commands += parameter_declaration.Notes;
		
		source_commands += ")\n Returns \n" ;
		
		source_commands += getFunctionElementProperties(ddl_Element); // to get Function element's properties		
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;	
}

function getFunctionElementProperties(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		var func_output as EA.TaggedValue;
		func_output = ddl_Element.TaggedValues.GetByName("Function Output");	
		
		if(func_output != null && func_output.Notes != "")
			source_commands += func_output.Notes + " \n";
		
		var cast_from as EA.TaggedValue;
		cast_from = ddl_Element.TaggedValues.GetByName("Cast From");	
		
		if(cast_from != null && cast_from.Notes != "")
			source_commands += "Cast From "+func_output.Notes+" \n" ;
		
		var specific_name as EA.TaggedValue;
		specific_name = ddl_Element.TaggedValues.GetByName("Specific Name");	
		
		if(specific_name != null && specific_name.Value != "")
			source_commands += "Specific "+specific_name.Value+" \n";
		
		var deterministic as EA.TaggedValue;
		deterministic =  ddl_Element.TaggedValues.GetByName("Deterministic");
		
		if(deterministic != null)
		{
			if(deterministic.Value == "Yes")
				source_commands += "Deterministic \n" ;
			else if(deterministic.Value == "No")
				source_commands += "Not Deterministic \n" ;			
		}
		
		var external_action as EA.TaggedValue;
		external_action = ddl_Element.TaggedValues.GetByName("External Action"); 
		
		if(external_action != null)
		{
			if(external_action.Value == "Yes")
				source_commands +=  "External Action \n";
			else if(external_action.Value == "No" )
				source_commands += "No External Action \n";			
		}
		
		var parallelized as EA.TaggedValue;
		parallelized = ddl_Element.TaggedValues.GetByName("Parallelized"); 
		
		if(parallelized != null)
		{
			if(parallelized.Value == "Allow")
			{
				source_commands += "Allow Parallel \n";
				
				var invoke_partition as EA.TaggedValue;
				invoke_partition =  ddl_Element.TaggedValues.GetByName("Invoked Partition"); 
				
				if(invoke_partition != null)
				{
					if(invoke_partition.Value == "Without Database")
						source_commands +=  "Execute On All Result Table Distributed \n";
					else if(invoke_partition.Value == "With Database")
						source_commands +=  "Execute On All Database Partitions Result Table Distributed \n";
				}		
			}
			else if(parallelized.Value == "DisAllow")
				source_commands += "DisAllow Parallel \n";
		}
		
		var not_secured as EA.TaggedValue;
		not_secured = ddl_Element.TaggedValues.GetByName("Invoked Partition"); 
		
		if(not_secured != null)
		{
			if(not_secured.Value == "Yes" )
				source_commands += "Secured \n";
			else if(not_secured.Value == "No")
				source_commands += "Not Secured \n";
		}
		
		var language as EA.TaggedValue;
		language = ddl_Element.TaggedValues.GetByName("Language"); 
		
		if(language != null && language.Value != "" && language.Value != "<none>")
			source_commands += "Language "+language.Value+"\n";
		
		var external_name as EA.TaggedValue;
		external_name = ddl_Element.TaggedValues.GetByName("External Name"); 
		
		var external as EA.TaggedValue;
		external = ddl_Element.TaggedValues.GetByName("External"); 
		
		if(external_name != null && external_name.Value != "")
			source_commands += "External Name "+external_name.Value+"\n";
		else if(external != null && external.Value == "True"&&external.Value != "")
			source_commands += "External ";
		
		var parameter_style as EA.TaggedValue;
		parameter_style = ddl_Element.TaggedValues.GetByName("Parameter Style"); 
		
		if(parameter_style != null && parameter_style.Value != "" && parameter_style.Value != "<none>")
			source_commands += "Parameter Style "+parameter_style.Value+" \n";
		
		var parameter_cssid as EA.TaggedValue;
		parameter_cssid = ddl_Element.TaggedValues.GetByName("Parameter CCSID"); 
		
		if(parameter_cssid != null && parameter_cssid.Value != "" && parameter_cssid.Value != "<none>")
			source_commands +=  "Parameter CCSID "+parameter_cssid.Value+" \n";
		
		var fenced as EA.TaggedValue;
		fenced = ddl_Element.TaggedValues.GetByName("Fenced"); 
		
		if(fenced != null)
		{
			if(fenced.Value == "Yes")
				source_commands += "Fenced \n";
			else if(fenced.Value == "No")
				source_commands += "Not Fenced \n";			
		}
		
		var thread_safe as EA.TaggedValue;
		thread_safe = ddl_Element.TaggedValues.GetByName("ThreadSafe"); 
		
		if(thread_safe != null)
		{
			if(thread_safe.Value == "Yes")
				source_commands += "ThreadSafe \n";
			else if(thread_safe.Value == "No")
				source_commands += "Not ThreadSafe \n";
		}
		
		var null_processing as EA.TaggedValue;
		null_processing = ddl_Element.TaggedValues.GetByName("Null Processing"); 
		
		if(null_processing != null)
		{
			if(null_processing.Value == "Returns")
				source_commands += "Returns Null On Null Input \n";
			else if(null_processing.Value == "Called")
				source_commands += "Called On Null Input \n";
			
		}
		
		var access_mode as EA.TaggedValue;
		access_mode = ddl_Element.TaggedValues.GetByName("Access Modes"); 
		
		if(access_mode != null)
		{
			if(access_mode.Value == "Reads")
				source_commands += "Reads SQL Data \n";
			else if(access_mode.Value == "No")
				source_commands += "No SQL \n";
			else if(access_mode.Value == "Contains")
				source_commands += "Contains SQL \n";
			else if(access_mode.Value == "Modifies")
				source_commands += "Modifies SQL Data \n";
		}
		
		var static_dispatch as EA.TaggedValue;
		static_dispatch = ddl_Element.TaggedValues.GetByName("Static Dispatch"); 
		
		if(static_dispatch != null && static_dispatch.Value == "True")
			source_commands += "Static Dispatch \n";
		
		var scratchpad as EA.TaggedValue;
		scratchpad = ddl_Element.TaggedValues.GetByName("Scratchpad"); 
		
		if(scratchpad != null)
		{
			if(scratchpad.Value == "Yes")
				source_commands += "Scratchpad \n";
			else if(scratchpad.Value == "No")
				source_commands += "No Scratchpad \n";
		}

		var final_call as EA.TaggedValue;
		final_call = ddl_Element.TaggedValues.GetByName("Final Call"); 
		
		if(final_call != null)
		{
			if(final_call.Value == "Yes")
				source_commands +=  "Final Call \n";
			else if(final_call.Value == "No")
				source_commands +=  "No Final Call \n";
		}
		
		var dbinfo as EA.TaggedValue;
		dbinfo = ddl_Element.TaggedValues.GetByName("DBInfo"); 
		
		if(dbinfo != null)
		{
			if(dbinfo.Value == "Yes")
				source_commands += "DBInfo \n" ;
			else if(dbinfo.Value == "No")
				source_commands += "No DBInfo \n" ;
		}
		
		var transform_group as EA.TaggedValue;
		transform_group = ddl_Element.TaggedValues.GetByName("Transform Group"); 
		
		if(transform_group != null && transform_group.Value != "")
			source_commands += "Transform Group "+transform_group.Value+" \n";
		
		var predicates as EA.TaggedValue;
		predicates = ddl_Element.TaggedValues.GetByName("Predicates"); 
		
		if(predicates != null && predicates.Notes != "")
			source_commands += "Predicates ( "+predicates.Notes+" ) \n";
		
		var lock_request as EA.TaggedValue;
		lock_request = ddl_Element.TaggedValues.GetByName("Lock Request"); 
		
		if(lock_request != null)
		{
			if(lock_request.Value == "Yes")
				source_commands += "Inherit Isolation Level With Lock Request \n" ;
			else if(lock_request.Value == "No" )
				source_commands +=  "Inherit Isolation Level Without Lock Request \n" ;
		}
		
		var special_register as EA.TaggedValue;
		special_register = ddl_Element.TaggedValues.GetByName("Special Registers"); 
		
		if(special_register != null && special_register.Value == "True")
			source_commands += "Inherit Special Registers \n";
		
		var no_resident as EA.TaggedValue;
		no_resident = ddl_Element.TaggedValues.GetByName("No Resident"); 
		
		if(no_resident != null && no_resident.Value == "True")
			source_commands += "Stay Resident No \n";
		
		var called_on_null as EA.TaggedValue;
		called_on_null = ddl_Element.TaggedValues.GetByName("Called On Null"); 
		
		if(called_on_null != null)
		{
			if(called_on_null.Value == "Yes")
				source_commands += "Null Call \n";
			else if(called_on_null.Value == "No")
				source_commands += "Not Null Call \n";
		}		
		
		var cardinality as EA.TaggedValue;
		cardinality = ddl_Element.TaggedValues.GetByName("Cardinality"); 
		
		if(cardinality != null && cardinality.Value != "")
			source_commands +=  "Cardinality "+cardinality.Value+"\n";
		
		var funcdef as EA.TaggedValue;
		funcdef = ddl_Element.TaggedValues.GetByName("funcdef"); 
		
		if(funcdef != null && funcdef.Notes != "")
			source_commands += funcdef.Notes+"\n";
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
		is_replace = ddl_Element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			source_commands += "Or Replace ";
		
		source_commands += "Procedure "
		
		var database_schema as EA.TaggedValue;
		database_schema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(database_schema != null && database_schema.Value != "")
		{	
			if(	database_schema.Value.endsWith("."))					
				source_commands += database_schema.Value ;
			else
				source_commands += database_schema.Value + ".";
		}
		var nameval=namecheck(ddl_Element.Name);
		if(nameval>1)
			source_commands += "\""+ddl_Element.Name+"\"\n  ";	
		else
			source_commands += ddl_Element.Name + " \n ";
		
		source_commands += getProcedureProperties(ddl_Element);
		
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;
}

function getProcedureProperties(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		var parameter_declaration as EA.TaggedValue;
		parameter_declaration = ddl_Element.TaggedValues.GetByName("Parameter Declaration");	
		
		if(parameter_declaration != null && parameter_declaration.Notes != "")
			source_commands += "( "+parameter_declaration.Notes+" )\n";
		
		var secured_proc as EA.TaggedValue;
		secured_proc = ddl_Element.TaggedValues.GetByName("Sourced Procedure");	
		
		if(secured_proc != null && secured_proc.Notes != "")
			source_commands += secured_proc.Notes + "\n";
		
		var language as EA.TaggedValue;
		language = ddl_Element.TaggedValues.GetByName("Language"); 
		
		if(language != null && language.Value != "" && language.Value != "<none>")
			source_commands += "Language "+language.Value+"\n";
		
		var specific_name as EA.TaggedValue;
		specific_name = ddl_Element.TaggedValues.GetByName("Specific Name");	
		
		if(specific_name != null && specific_name.Value != "")
			source_commands += "Specific "+specific_name.Value+" \n";
		
		var result_sets as EA.TaggedValue;
		result_sets = ddl_Element.TaggedValues.GetByName("Result Sets"); 
		
		if(result_sets != null && result_sets.Value != "")
			source_commands += "Dynamic Result Sets "+result_sets.Value+"\n";
		
		var access_mode as EA.TaggedValue;
		access_mode = ddl_Element.TaggedValues.GetByName("Access Modes"); 
		
		if(access_mode != null)
		{
			if(access_mode.Value == "Reads")
				source_commands += "Reads SQL Data \n";
			else if(access_mode.Value == "No")
				source_commands += "No SQL \n";
			else if(access_mode.Value == "Contains")
				source_commands += "Contains SQL \n";
			else if(access_mode.Value == "Modifies")
				source_commands += "Modifies SQL Data \n";
		}
		
		var deterministic as EA.TaggedValue;
		deterministic =  ddl_Element.TaggedValues.GetByName("Deterministic");
		
		if(deterministic != null)
		{
			if(deterministic.Value == "Yes")
				source_commands += "Deterministic \n" ;
			else if(deterministic.Value == "No")
				source_commands += "Not Deterministic \n" ;			
		}
		
		var null_input as EA.TaggedValue;
		null_input = ddl_Element.TaggedValues.GetByName("Null Input");
		
		if(null_input != null && null_input.Value  == "True")
			source_commands += "Called On Null Input \n";
		
		var savepoint_level as EA.TaggedValue;
		savepoint_level = ddl_Element.TaggedValues.GetByName("SavePoint Level");
		
		if(savepoint_level != null && savepoint_level.Value != "" && savepoint_level.Value != "<none>")
			source_commands += savepoint_level.Value+" SavePoint Level \n";
		
		var external_name as EA.TaggedValue;
		external_name = ddl_Element.TaggedValues.GetByName("External Name"); 
		
		if(external_name != null && external_name.Value != "")
			source_commands += "External Name "+external_name.Value+"\n";
		
		var fenced as EA.TaggedValue;
		fenced = ddl_Element.TaggedValues.GetByName("Fenced"); 
		
		if(fenced != null)
		{
			if(fenced.Value == "Yes")
				source_commands += "Fenced \n";
			else if(fenced.Value == "No")
				source_commands += "Not Fenced \n";			
		}
		
		var thread_safe as EA.TaggedValue;
		thread_safe = ddl_Element.TaggedValues.GetByName("ThreadSafe"); 
		
		if(thread_safe != null)
		{
			if(thread_safe.Value == "Yes")
				source_commands += "ThreadSafe \n";
			else if(thread_safe.Value == "No")
				source_commands += "Not ThreadSafe \n";
		}
		
		var special_register as EA.TaggedValue;
		special_register = ddl_Element.TaggedValues.GetByName("Special Registers"); 
		
		if(special_register != null && special_register.Value == "True")
			source_commands += "Inherit Special Registers \n";
		
		var parameter_style as EA.TaggedValue;
		parameter_style = ddl_Element.TaggedValues.GetByName("Parameter Style"); 
		
		if(parameter_style != null && parameter_style.Value != "" && parameter_style.Value != "<none>")
			source_commands += "Parameter Style "+parameter_style.Value+" \n";
		
		var parameter_cssid as EA.TaggedValue;
		parameter_cssid = ddl_Element.TaggedValues.GetByName("Parameter CCSID"); 
		
		if(parameter_cssid != null && parameter_cssid.Value != "" && parameter_cssid.Value != "<none>")
			source_commands +=  "Parameter CCSID "+parameter_cssid.Value+" \n";
		
		var program_type as EA.TaggedValue;
		program_type = ddl_Element.TaggedValues.GetByName("Program Type"); 
		
		if(program_type != null && program_type.Value != "<none>" && program_type.Value != "")
			source_commands += "Program Type "+program_type.Value+" \n" ;
		
		var dbinfo as EA.TaggedValue;
		dbinfo = ddl_Element.TaggedValues.GetByName("DBInfo"); 
		
		if(dbinfo != null)
		{
			if(dbinfo.Value == "Yes")
				source_commands += "DBInfo \n" ;
			else if(dbinfo.Value == "No")
				source_commands += "No DBInfo \n" ;
		}
		
		var no_resident as EA.TaggedValue;
		no_resident = ddl_Element.TaggedValues.GetByName("No Resident"); 
		
		if(no_resident != null && no_resident.Value == "True")
			source_commands += "Stay Resident No \n";
		
		var return_to as EA.TaggedValue;
		return_to = ddl_Element.TaggedValues.GetByName("Return To"); 
		
		if(return_to != null && return_to.Value != "" && return_to.Value != "<none>")
			source_commands += "With Return To "+return_to.Value+" All \n";
		
		var external_action as EA.TaggedValue;
		external_action = ddl_Element.TaggedValues.GetByName("External Action"); 
		
		if(external_action != null)
		{
			if(external_action.Value == "Yes")
				source_commands +=  "External \n";
			else if(external_action.Value == "No" )
				source_commands += "No External \n";			
		}
		
		var commit_on_return as EA.TaggedValue;
		commit_on_return = ddl_Element.TaggedValues.GetByName("Commit On Return"); 
		
		if(commit_on_return != null)
		{
			if(commit_on_return.Value == "Yes")
				source_commands += "Commint On Return Yes \n";
			else if(commit_on_return.Value == "No")
				source_commands += "Commint On Return No \n";			
		}
		
		var autonomous as EA.TaggedValue;
		autonomous = ddl_Element.TaggedValues.GetByName("Autonomous"); 
		
		if(autonomous != null && autonomous.Value == "True")
			source_commands += "Autonomous \n";
		
		var procdef as EA.TaggedValue;
		procdef = ddl_Element.TaggedValues.GetByName("procdef"); 
		
		if(procdef != null && procdef.Notes != "")
			source_commands += procdef.Notes+"\n";		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	return source_commands;
}

function namecheck(Element_name)
{
	var name="";
	name=Element_name;
	var split_name=[];
	split_name=name.split(" ");
	
	return split_name.length;
	
}


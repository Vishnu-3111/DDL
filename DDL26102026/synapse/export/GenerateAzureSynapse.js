!INC Local Scripts.EAConstants-JavaScript
/* 
  This script is applied for Azure Synapse database only
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
	var alter_commands = "";	
	
	if(ddl_Element.FQStereotype == "AzureSynapse::table") // if the given element was table 
	{	
		var table_commands = getTableElements(ddl_Element,columns,constraints,fk_connector,reference_table,constraints_value); // method for get table elements and their properties
		
		source_commands = table_commands[0];
		index = table_commands[1];
		alter_commands = table_commands[2];			
	}
	else if(ddl_Element.FQStereotype == "AzureSynapse::view")// if the given element was view
		source_commands = getViewElements(ddl_Element); // method for get view elements and their properties	
	else if(ddl_Element.FQStereotype == "AzureSynapse::function")// if the given element was function
		source_commands = getFunctionElement(ddl_Element);	// method for get function elements and their properties	 
	else if(ddl_Element.FQStereotype == "AzureSynapse::procedure")// if the given element was procedure
		source_commands = getProcedureElements(ddl_Element); //method for get procedure elements and their properties
	
	source_commands += ";\n";	
	
	source_commands += "GO\n";	
	
	if(index != "" ) 
		source_commands += "\n\n"+index;
	
	if(alter_commands != ""&&alter_commands!="  ")
		source_commands += "\n\n"+alter_commands+" ;\n";
		
	source_Filepath.WriteLine(source_commands+"\n");	
}

function getTableElements(ddl_Element,columns,constraints,fk_connector,reference_table,constraints_value)
{
	var source_commands = "";
	var index = "";
	var alter_commands = "";
	
	try
	{
		var table_type as EA.TaggedValue;
		table_type = ddl_Element.TaggedValues.GetByName("Table Type"); // To get Table Type tag from MDG to initiate the Create table Command

		if(table_type != null && table_type.Value == "External")
			source_commands = "Create external table ";
		else
			source_commands = "Create table ";	// To write the Create table Command if table type is none or others 		

		var fq_table_name as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
			fq_table_name = ddl_Element.TaggedValues.GetByName("Schema and Database"); 

		if(fq_table_name != null && fq_table_name.Value != "")
		{
			source_commands += fq_table_name.Value;
		}

		source_commands += "["+ddl_Element.Name +"]\n";

		if(ddl_Element.Attributes.Count != 0)
			source_commands += "("  + "\n" ;	
		
		source_commands += getColumn(ddl_Element,columns);	// method for using get columns and their properties
		
		var table_constraint = getTableConstraint(ddl_Element,constraints,constraints_value,fk_connector,reference_table); // method for using get constraint and their properties
		
		index += table_constraint[0];
		alter_commands += table_constraint[1];

		
		if(ddl_Element.Attributes.Count != 0)
			source_commands +=  "\n)\n"   ;	

		// To include additional commands from the "AzureSynapse::table" Tagged values in source_commands
		
		source_commands += getTableProperties(ddl_Element,table_type); // method for using get table's additional properties
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}

	return [source_commands,index,alter_commands];	
}

function getColumn(ddl_Element,columns)
{
	var source_commands = "";
	
	try
	{
		for(var j=0 ; j<ddl_Element.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = ddl_Element.Attributes.GetAt(j);
			source_commands += "["+columns.Name + "] " + columns.Type+" "; 	

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

			// To include additional commands from the "AzureSynapse::column" Tagged values in source_commands

			var collate as EA.TaggedValue;
			collate = columns.TaggedValues.GetByName("Collate");

			if(collate != null && collate.Value !="")
				source_commands += "Collate "+collate.Value+" ";			

			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if (NotNull)
				source_commands += "Not Null ";

			source_commands += get_inlineConstraint(ddl_Element,columns);

			var identity as EA.TaggedValue;
			identity = columns.TaggedValues.GetByName("Identity");

			if(identity != null && identity.Value !="")
				source_commands += "Identity "+identity.Value+" ";

			var constraint as EA.TaggedValue;
			constraint = columns.TaggedValues.GetByName("Constraint");

			if(constraint != null && constraint.Value != "")
				source_commands += "Constraint " +constraint.Value+" ";

			var col_default = columns.Default;

			if(col_default != "")
				source_commands += "Default " +col_default+" ";

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

function get_inlineConstraint(ddl_Element,columns)
{
	var query = "select tConst.Stereotype as Operation_Stereotype \n" +
		"from \n" +
		"    t_operation tConst \n" +
		"inner join \n" +
		"    t_operationtag const_tag on const_tag.ElementID = tConst.OperationID \n" +
		"inner join \n" +
		"    t_attribute tCol on tCol.Object_ID = tConst.Object_ID \n" +
		"inner join \n" +
		"    t_operationparams const_val on const_val.OperationID = tConst.OperationID \n" +
		"inner join \n" +
		"    t_object table_name on table_name.Object_ID = tConst.Object_ID " +
		"where \n" +
		"    const_tag.Property = 'Inline Constraint' and \n" +
		"    const_tag.VALUE = 'True' and \n" +
		"    const_val.Name = tCol.Name and \n" +
		"    tCol.ID = "+columns.AttributeID+" and \n" +
		"    table_name.Object_ID = "+ddl_Element.ElementID+" \n";
	
	var conn_string = Repository.ConnectionString;
	var exe_query= "";
	
	if(conn_string.endsWith(".feap"))
		exe_query = Repository.SQLQuery(query.replace('const_tag.VALUE', 'const_tag.\"VALUE\"'));
	else
		exe_query  = Repository.SQLQuery(query);
	
	if(exe_query == "")
		exe_query = Repository.SQLQuery(query.replace('const_tag.VALUE', 'const_tag.\"VALUE\"'));

	var inline_Constraint_type = "";
	
	var xmlDOM = new COMObject("MSXML2.DOMDocument");
	xmlDOM.validateOnParse = false;
	xmlDOM.async = false;
	
	var parsed = xmlDOM.loadXML(exe_query);

	if (parsed) 
	{
		var nodes = xmlDOM.selectNodes("//Operation_Stereotype");
		inline_Constraint_type = nodes.context.text;
	}	
	
	if(inline_Constraint_type == "PK")
		inline_Constraint_type = "Primary Key";
	else if(inline_Constraint_type == "unique")
		inline_Constraint_type = "Unique";
	
	return inline_Constraint_type;
}

function getTableConstraint(ddl_Element,constraints,constraints_value,fk_connector,reference_table)
{
	index = "";
	alter_commands = "";
	
	try
	{
		var schema_and_database as EA.TaggedValue;
		schema_and_database = ddl_Element.TaggedValues.GetByName("Schema and Database");
				
		var table_name = schema_and_database.Value+"["+ddl_Element.Name+"]";

		for(var k=0 ; k<ddl_Element.Methods.Count ; k++ ) // To get the column constraints from the given table element
		{
			constraints = ddl_Element.Methods.GetAt(k);

			var ol_const = false;

			var inline_const as EA.TaggedValue;
			inline_const = constraints.TaggedValues.GetByName("Inline Constraint");	

			if(inline_const != null && (inline_const.Value == "" ||inline_const.Value == "False" ) )
				ol_const = true;		   


			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "index" || constraints.Stereotype == "check")
			{
				if(constraints.Stereotype == "PK" && ol_const ) // if the constraints was primary key
				{	
								
					if(!alter_commands.startsWith("Alter Table "+table_name))
						alter_commands += "Alter Table "+table_name+"\n" ;
					
					if(k!=0)
						alter_commands += ",\n"
					else
						alter_commands += "Add \n"
					
					if(constraints.Name == "")						
						alter_commands += "primary key (" ; 	
					else
						alter_commands +=  "Constraint "+constraints.Name+" primary key (" ; 
				}
				else if(constraints.Stereotype == "unique" && ol_const) // if the constraints was unique
				{
					
					if(!alter_commands.startsWith("Alter Table "+table_name))
						alter_commands += "Alter Table "+table_name+"\n" ;
					
					if(k!=0)
						alter_commands += ",\n"
					else
						alter_commands += "Add \n"
					
					if(constraints.Name == "")						
						alter_commands += "unique (" ; 	
					else
						alter_commands +=  "Constraint "+constraints.Name+" unique (" ; 					
					
				}	
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					ol_const = true;
					
					if(!alter_commands.startsWith("Alter Table "+table_name))
						alter_commands += "Alter Table "+table_name+"\n" ;
					
					if(k!=0)
						alter_commands += ",\n"
					else
						alter_commands += "Add \n"
					
					if(constraints.Name == "")	
						alter_commands += "foreign key (";
					else 
						alter_commands +=  "Constraint "+constraints.Name+" foreign key (" ; 
				}
				else if(constraints.Stereotype == "check")
				{
					ol_const = true;
					
					if(!alter_commands.startsWith("Alter Table "+table_name))
						alter_commands += "Alter Table "+table_name+"\n" ;
					
					if(k!=0)
						alter_commands += ",\n"
					else
						alter_commands += "Add \n"
					
					if(constraints.Name == "")						
						alter_commands += "Check (" ; 	
					else
						alter_commands +=  "Constraint "+constraints.Name+" Check ("+ constraints.Code;					
					
					
				}
				else if(constraints.Stereotype == "index") // if the constraints was index
				{	
					index += "Create ";
					
					var is_unique as EA.TaggedValue;
					is_unique = constraints.TaggedValues.GetByName("Unique");
					
					if(is_unique != null)
					{
						if(is_unique.Value == "1" || is_unique.Value == "TRUE")
							index += "Unique ";
					}
					
					var is_clustered as EA.TaggedValue;
					is_clustered = constraints.TaggedValues.GetByName("Clustered");
					
					if(is_clustered != null)
					{
						if(is_clustered.Value == "1" || is_clustered.Value == "TRUE")
							index += "Clustered ";
					}

					var columnstore as EA.TaggedValue;
					columnstore = constraints.TaggedValues.GetByName("Is Columnstore");
					
					if(columnstore != null && columnstore.Value == "True")
						index += "Columnstore ";
					
					index += "Index " +constraints.Name+" on ["+ddl_Element.Name+ "] ";
					
					if(constraints.Parameters.Count != 0)
						index += "(";
					
				}
				
				var constraint_parameter = getConstraintParameter(constraints,constraints_value,ol_const); //method for using get constraint parameters
				
				index += constraint_parameter[0];
				alter_commands += constraint_parameter[1]+" ";		
					
				alter_commands += getForeignKeyReference(constraints,fk_connector,ddl_Element,reference_table);	 //method for using get foreign key reference table 
			}			
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [index,alter_commands];
	
}

function getConstraintParameter(constraints,constraints_value,ol_const)
{
	var index = "";
	var alter_commands = "";
	
	try
	{		
		for(var l=0 ; l<constraints.Parameters.Count ; l++ )// to get constraints column names
		{
			constraints_value = constraints.Parameters.GetAt(l);
			if(l>0)
			{
				if(constraints.Stereotype == "index")
					index += ",";
				else if(ol_const)
					alter_commands += ','; 
			}
					
			if(constraints.Stereotype == "index")
				index += "["+constraints_value.Name+"]";					
			else if(ol_const)
				alter_commands += "["+constraints_value.Name+"]";	
		
		}
		
		if(constraints.Stereotype == "index")
		{
			if(constraints.Parameters.Count != 0)
				index += ")\n";	
			
			var order_by as EA.TaggedValue;
			order_by = constraints.TaggedValues.GetByName("Order By");
			
			if(order_by != null && order_by.Notes != "")
				index += "Order (" + order_by.Notes + ")\n";
			
			var relational_index_option as EA.TaggedValue;
			relational_index_option = constraints.TaggedValues.GetByName("Relational Index Option");
			
			if(relational_index_option != null && relational_index_option.Notes != "")
				index += "With (" + relational_index_option.Notes + ")\n";
			
			var include as EA.TaggedValue;
			include = constraints.TaggedValues.GetByName("Include");
			
			if(include != null && include.Notes != "")
				index += "Include " + include.Notes + "\n";
			
			var where_condition as EA.TaggedValue;
			where_condition = constraints.TaggedValues.GetByName("Where Condition");
			
			if(where_condition != null && where_condition.Notes != "")
				index += "Where " + where_condition.Notes + "\n";
			
			var on_value as EA.TaggedValue;
			on_value = constraints.TaggedValues.GetByName("On Value");
			
			if(on_value != null && on_value.Notes != "")
				index += "On " + on_value.Notes + "\n";
			
			var file_stream as EA.TaggedValue;
			file_stream = constraints.TaggedValues.GetByName("Filestream On");
			
			if(file_stream != null && file_stream.Notes != "")
				index += "Filestream_On " + file_stream.Notes + "\n";					
			
			index += ";\n\n";
		}
		else if(ol_const)
			alter_commands  += ")";			
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [index,alter_commands];
	
}

function getForeignKeyReference(constraints,fk_connector,ddl_Element,reference_table)
{
	var alter_commands = "" ;
	
	try
	{
		if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "AzureSynapse::FK" connector
		{
			for(var f=0 ; f<ddl_Element.Connectors.Count ; f++)
			{
				fk_connector = ddl_Element.Connectors.GetAt(f);

				if(fk_connector.FQStereotype == "AzureSynapse::FK" && fk_connector.ClientEnd.Role == constraints.Name)
				{
					var col_ref as EA.Method;
					
					reference_table = Repository.GetElementByID(fk_connector.SupplierID);
					
					var ref_schema as EA.TaggedValue;
					ref_schema = reference_table.TaggedValues.GetByName("Schema and Database");
					
					var fq_table_name = ref_schema.Value+"["+reference_table.Name+"]";

					alter_commands += "References "+fq_table_name+" ";
					
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
							
						ref_column_names += "["+constraints_value.Name+"]";
						}

						alter_commands += "("+ref_column_names+") ";
					}
				}	
			}
			
			var on_update as EA.TaggedValue;
			on_update = constraints.TaggedValues.GetByName("Update");
			
			if(on_update != null && on_update.Value != "")
				alter_commands += "On Update "+on_update.Value+" ";
			
			var on_delete as EA.TaggedValue;
			on_delete = constraints.TaggedValues.GetByName("Delete");
			
			if(on_delete != null && on_delete.Value != "")
				alter_commands += "On Delete " +on_delete.Value+" ";
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return alter_commands;
	
}

function getTableProperties(ddl_Element,table_type)
{
	var source_commands = "";
	
	try
	{
		var with_optionvalues = "";

		var columnstore_value = "";

		var columnstore_index as EA.TaggedValue;
		columnstore_index = ddl_Element.TaggedValues.GetByName("Columnstore Index");

		if(columnstore_index != null && columnstore_index.Value == "True" && (table_type.Value == "<none>" || table_type.Value == "" ))
			columnstore_value += "Clustered Columnstore Index " ;

		var index_order as EA.TaggedValue;
		index_order = ddl_Element.TaggedValues.GetByName("Index Order");

		if(index_order != null && index_order.Notes != "" && columnstore_index.Value == "True"  && (table_type.Value == "<none>" || table_type.Value == "" ))
		columnstore_value += "Order ("+index_order.Notes + ")";

		if(columnstore_value != "")
			with_optionvalues += columnstore_value+ ",\n" ;	

		var heap as EA.TaggedValue;
		heap = ddl_Element.TaggedValues.GetByName("Heap");

		if(heap != null && heap.Value == "True" && (table_type.Value == "<none>" || table_type.Value == "" ))
		with_optionvalues += "Heap,\n" ;

		var clustered_index as EA.TaggedValue;
			clustered_index = ddl_Element.TaggedValues.GetByName("Clustered Index");

		if(clustered_index != null && clustered_index.Notes != "" && (table_type.Value == "<none>" || table_type.Value == "" ))
		with_optionvalues += "Clustered Index "+clustered_index.Notes+",\n";

		var distribution as EA.TaggedValue;
		distribution = 	ddl_Element.TaggedValues.GetByName("Distribution");

		if(distribution != null && distribution.Value != "" && (table_type.Value == "<none>" || table_type.Value == "" ))
			with_optionvalues += "Distribution = "+distribution.Value+",\n";

		var partition as EA.TaggedValue;
		partition = ddl_Element.TaggedValues.GetByName("Partition");

		if(partition != null && partition.Notes != "" && (table_type.Value == "<none>" || table_type.Value == "" ))
			with_optionvalues += "Partition "+partition.Notes+",\n" ;

		var for_append as EA.TaggedValue;
		for_append = ddl_Element.TaggedValues.GetByName("For Append");

		if(for_append != null && for_append.Value == "True"&& (table_type.Value == "<none>" || table_type.Value == "" ))
			with_optionvalues += "For_Append,\n" ;

		var location as EA.TaggedValue;
		location = 	ddl_Element.TaggedValues.GetByName("Location");

		if(location != null && location.Value != "" && table_type.Value == "External" )
		with_optionvalues += "Location = "+location.Value+",\n";

		var data_source as EA.TaggedValue;
		data_source = 	ddl_Element.TaggedValues.GetByName("Data Source");

		if(data_source != null && data_source.Value != "" && table_type.Value == "External" )
			with_optionvalues += "Data_Source = "+data_source.Value+",\n";

		var file_format as EA.TaggedValue;
		file_format = 	ddl_Element.TaggedValues.GetByName("File Format");

		if(file_format != null && file_format.Value != "" && table_type.Value == "External" )
			with_optionvalues += "File_Format = "+file_format.Value+",\n";

		var reject_type as EA.TaggedValue;
		reject_type = 	ddl_Element.TaggedValues.GetByName("Reject Type");

		if(reject_type != null && reject_type.Value != "" && table_type.Value == "External" )
			with_optionvalues += "Reject_Type = "+reject_type.Value+",\n";

		var reject_value as EA.TaggedValue;
		reject_value = 	ddl_Element.TaggedValues.GetByName("Reject Value");

		if(reject_value != null && reject_value.Value != "" && table_type.Value == "External" )
			with_optionvalues += "Reject_Value = "+reject_value.Value+",\n";

		var reject_row_location as EA.TaggedValue;
		reject_row_location = 	ddl_Element.TaggedValues.GetByName("Reject Row Location");

		if(reject_row_location != null && reject_row_location.Value != "" && table_type.Value == "External" )
			with_optionvalues += "Reject_Row_Location = "+reject_row_location.Value+",\n";

		var table_option as EA.TaggedValue;
		table_option = 	ddl_Element.TaggedValues.GetByName("Table Option");

		if(table_option != null && table_option.Value != "" && table_type.Value == "External" )
			with_optionvalues += "Table Options = "+table_option.Value+",\n";

		if (with_optionvalues.endsWith(",\n"))
			with_optionvalues = with_optionvalues.slice(0, -2);		

		if(with_optionvalues != "")
			source_commands += "With (\n"+ with_optionvalues+ "\n)\n";	

		var select_query as EA.TaggedValue;
		select_query = ddl_Element.TaggedValues.GetByName("Select Query");

		if(select_query != null && select_query.Notes != "")
			source_commands += "As " + select_query.Notes+ "\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands ;	
}

function getViewElements(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		source_commands =  "Create ";
		
		var is_alter as EA.TaggedValue;
		is_alter = ddl_Element.TaggedValues.GetByName("Alter"); 
		
		if(is_alter != null && is_alter.Value == "True")
			source_commands += "Or Alter ";
		
		var is_mat as EA.TaggedValue;
		is_mat = ddl_Element.TaggedValues.GetByName("Materialized"); 
		
		if(is_mat !=  null && is_mat.Value == "True")
			source_commands += "Materialized ";		
		
		source_commands +=  "View ";	
		
		var fq_view_name as EA.TaggedValue; // To get the fully qualified view name from "Schema and Database" tagged value
		fq_view_name = ddl_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_view_name != null && fq_view_name.Value != "")
			source_commands += fq_view_name.Value;
		
		source_commands += "["+ddl_Element.Name +"]\n";
		
		// To include additional commands from the "AzureSynapse::view" Tagged values in source_commands
		
		source_commands += getViewProperties(ddl_Element,is_mat); // method for get View Properties		
				
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	
	return source_commands;	
}

function getViewProperties(ddl_Element,is_mat)
{
	var source_commands = "";
	
	try
	{
		var view_columns as EA.TaggedValue;
		view_columns = ddl_Element.TaggedValues.GetByName("Columns");
		
		if(view_columns != null && view_columns.Notes != "")
			source_commands += "Columns "+view_columns.Notes;
		
		var with_table_option = "";
		
		var columnstore_index as EA.TaggedValue;
		columnstore_index = ddl_Element.TaggedValues.GetByName("Columnstore Index");
		
		if(columnstore_index != null && columnstore_index.Notes != "" && (is_mat.Value == "True" ))
			with_table_option += "Clustered Columnstore Index "+columnstore_index.Notes+",\n" ;
		
		var heap as EA.TaggedValue;
		heap = ddl_Element.TaggedValues.GetByName("Heap");
		
		if(heap != null && heap.Value == "True" && (is_mat.Value == "True"))
			with_table_option += "Heap,\n" ;
		
		var clustered_index as EA.TaggedValue;
		clustered_index = ddl_Element.TaggedValues.GetByName("Clustered Index");
		
		if(clustered_index != null && clustered_index.Notes != "" && (is_mat.Value == "True" ))
			with_table_option += "Clustered Index "+clustered_index.Notes+",\n";
		
		var distribution as EA.TaggedValue;
		distribution = 	ddl_Element.TaggedValues.GetByName("Distribution");
		
		if(distribution != null && distribution.Value != "" && (is_mat.Value == "True"))
			with_table_option += "Distribution = "+distribution.Value+",\n";

		var partition as EA.TaggedValue;
		partition = ddl_Element.TaggedValues.GetByName("Partition");
		
		if(partition != null && partition.Notes != "" && (is_mat.Value == "True" ))
			with_table_option += "Partition "+partition.Notes+",\n" ;
		
		var for_append as EA.TaggedValue;
		for_append = ddl_Element.TaggedValues.GetByName("For Append");
		
		if(for_append != null && for_append.Value == "True"&& (is_mat.Value == "True" ))
			with_table_option += "For_Append,\n" ;		
		
		if (with_table_option.endsWith(",\n"))
			with_table_option = with_table_option.slice(0, -2);	
		
		if(with_table_option != "")
			source_commands += "With (\n"+ with_table_option+ "\n)\n";	
		
		var with_view_attribute = "";
		
		var encryption as EA.TaggedValue;
		encryption = ddl_Element.TaggedValues.GetByName("Encryption");
		
		if(encryption != null && encryption.Value == "True"&& (is_mat.Value != "True" ))
			with_view_attribute += "Encryption, " ;	 
		
		var scheme_binding as EA.TaggedValue;
		scheme_binding = ddl_Element.TaggedValues.GetByName("SchemaBinding");
		
		if(scheme_binding != null && scheme_binding.Value == "True"&& (is_mat.Value != "True" ))
			with_view_attribute += "SchemaBinding, " ;	 
		
		var view_metadata as EA.TaggedValue;
		view_metadata = ddl_Element.TaggedValues.GetByName("View Metadata");
		
		if(view_metadata != null && view_metadata.Value == "True"&& (is_mat.Value != "True" ))
			with_view_attribute += "View_Metadata, " ;	
		
		if (with_view_attribute.endsWith(", "))
			with_view_attribute = with_view_attribute.slice(0, -2);	
		
		if(with_view_attribute != "")
			source_commands += "With "+ with_view_attribute+" \n";	
		
		var view_def as EA.TaggedValue;
		view_def = ddl_Element.TaggedValues.GetByName("viewdef");
		
		if(view_def != null && view_def.Notes != "")
			source_commands += "As " + view_def.Notes+ "\n";		
		
		var check_option as EA.TaggedValue;		
		check_option = ddl_Element.TaggedValues.GetByName("Check Option");
		
		if(check_option != null && check_option.Value == "True")
			source_commands += "With Check Option \n";	
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;	
}

function getFunctionElement(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		source_commands = "Create Function ";
		
		var fq_func_name as EA.TaggedValue; // To get the fully qualified function name from "Schema and Database" tagged value
		fq_func_name = ddl_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_func_name != null && fq_func_name.Value != "")
			source_commands += fq_func_name.Value;
		
		source_commands += "["+ddl_Element.Name +"]\n";
		
		// To include additional commands from the "AzureSynapse::function" Tagged values in source_commands
		
		source_commands += getFunctionProperties(ddl_Element); // method for using get function additional properties		
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	
	return source_commands ;
}

function getFunctionProperties(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		var parameter as EA.TaggedValue;
		parameter = ddl_Element.TaggedValues.GetByName("Parameter");
		
		if(parameter != null && parameter.Notes != "")
			source_commands += parameter.Notes+"\n";
		
		var return_value as EA.TaggedValue;
		return_value = ddl_Element.TaggedValues.GetByName("Returns");
		
		if(return_value != null && return_value.Value != "")
			source_commands += "Returns "+return_value.Value+ "\n";
		
		var with_function_option = "";
		
		var schema_binding as EA.TaggedValue;
		schema_binding = ddl_Element.TaggedValues.GetByName("SchemaBinding");
		
		if(schema_binding != null && schema_binding.Value == "True")
			with_function_option += "SchemaBinding, ";
		
		var returns_null as EA.TaggedValue;
		returns_null = ddl_Element.TaggedValues.GetByName("Returns Null");
		
		if(returns_null != null && returns_null.Value == "True")
			with_function_option += "Returns Null on Null Input, ";
		
		var called_null as EA.TaggedValue;
		called_null = ddl_Element.TaggedValues.GetByName("Called Null");
		
		if(called_null != null && called_null.Value == "True")
			with_function_option += "Called on Null Input, ";
		
		if (with_function_option.endsWith(", "))
			with_function_option = with_function_option.slice(0, -2);	
		
		if(with_function_option != "")
			source_commands += "With "+ with_function_option+" \n";	
		
		var func_def as EA.TaggedValue;
		func_def = ddl_Element.TaggedValues.GetByName("funcdef");
		
		if(func_def != null && func_def.Notes != "")
			source_commands += "As \n"+func_def.Notes+"\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands ;		
}

function getProcedureElements(ddl_Element)
{
	var source_commands = "" ;
	
	try
	{
		var isAlter as EA.TaggedValue;  // To get the is alter value to initiate the Create procedure command
		isAlter = ddl_Element.TaggedValues.GetByName("Alter"); 
		
		if(isAlter != null && isAlter.Value == "True")
			source_commands = "Create Or Alter Procedure " ;
		else
			source_commands = "Create Procedure "; // To write the Create procedure Command if alter is false or others 
		
		var fq_proc_name as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		fq_proc_name = ddl_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_proc_name != null && fq_proc_name.Value != "")
			source_commands += fq_proc_name.Value;
		
		source_commands += "["+ddl_Element.Name +"]\n";		
		
		// To include additional commands from the "AzureSynapse::function" Tagged values in source_commands		
		source_commands += getProcedureProperties(ddl_Element) ; // method for using get procedure's additional properties	
		
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
		var parameter as EA.TaggedValue;
		parameter = ddl_Element.TaggedValues.GetByName("Parameter");
		
		if(parameter != null && parameter.Notes != "")
			source_commands += parameter.Notes +"\n"; 
		
		var varing as EA.TaggedValue;
		varing = ddl_Element.TaggedValues.GetByName("Varying");
		
		if(varing != null && varing.Value == "True")
			source_commands += "Varying \n";
		
		var is_null as EA.TaggedValue;
		is_null = ddl_Element.TaggedValues.GetByName("IsNull");		
	
		
		if(is_null != null && is_null.Value == "True")
			source_commands += "Null \n";
		
		var parm_default as EA.TaggedValue;
		parm_default = ddl_Element.TaggedValues.GetByName("Default Parameter");
		
		if(parm_default != null && parm_default.Value != "")
			source_commands += "= "+parm_default.Value+" \n";
		
		var parm_option as EA.TaggedValue;
		parm_option = ddl_Element.TaggedValues.GetByName("Parameter Option");
		
		if(parm_option != null && parm_option.Value != "")
			source_commands += parm_option.Value+" \n";
		
		var with_proc_value = "";
		
		var encrypt as EA.TaggedValue;
		encrypt = ddl_Element.TaggedValues.GetByName("Encryption");
		
		if(encrypt != null && encrypt.Value == "True")
			with_proc_value += "Encryption, ";
		
		var recompile as EA.TaggedValue;
		recompile = ddl_Element.TaggedValues.GetByName("Recompile");
		
		if(recompile != null && recompile.Value == "True")
			with_proc_value += "Recompile, ";
		
		var execute_as as EA.TaggedValue;
		execute_as = ddl_Element.TaggedValues.GetByName("Execute As");
		
		if(execute_as != null && execute_as.Value != "")
			with_proc_value += "Execute As "+ execute_as.Value+ ", ";
		
		var native_compilation as EA.TaggedValue;
		native_compilation = ddl_Element.TaggedValues.GetByName("Native Compilation");
		
		if(native_compilation != null && native_compilation.Value == "True")
			with_proc_value += "Native_Compilation, ";
		
		var schemaBinding as EA.TaggedValue;
		schemaBinding = ddl_Element.TaggedValues.GetByName("SchemaBinding");
		
		if(schemaBinding != null && schemaBinding.Value == "True")
			with_proc_value += "SchemaBinding, ";
		
		
		if (with_proc_value.endsWith(", "))
			with_proc_value = with_proc_value.slice(0, -2);	
		
		if(with_proc_value != "")
			source_commands += "With "+ with_proc_value+" \n";	
		
		var for_replication as EA.TaggedValue;
		for_replication = ddl_Element.TaggedValues.GetByName("For Replication");
		
		if(for_replication != null && for_replication.Value == "True")
			source_commands += "For Replication \n";
		
		var proc_def as EA.TaggedValue;
		proc_def = ddl_Element.TaggedValues.GetByName("procdef");
		
		if(proc_def != null && proc_def.Notes != "")
			source_commands += "As \n"+proc_def.Notes+"\n";		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;
}

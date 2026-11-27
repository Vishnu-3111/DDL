!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for MsAccess database only
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
	if(ddl_Element.FQStereotype == "MsAccess::table") // if the given element was table 
	{
		var table_commands = getTableElements(ddl_Element,columns,constraints,constraints_value,fk_connector,reference_table);	  // to get Table Elements and its properties
		source_commands = table_commands[0];
		index = table_commands[1];		
	}
	else if(ddl_Element.FQStereotype == "MsAccess::view") // if the given element was view 
		source_commands = getViewElements(ddl_Element);	// to get view elements and its properties	
	else if(ddl_Element.FQStereotype == "MsAccess::procedure") // if the given element was procedure
		source_commands = getProcedureElements(ddl_Element); 	// to get procedure elements and its properties			
	
	if(source_commands != "")
		source_commands += ";";	
	
	if(index != "" )
		source_commands += "\n\n"+index;
	
	source_Filepath.WriteLine(source_commands + "\n");
}


function getTableElements(ddl_Element,columns,constraints,constraints_value,fk_connector,reference_table)
{
	var source_commands = "";
	var index = "";
	
	try
	{
		source_commands = "Create ";
		
		var temp_table as EA.TaggedValue;
		temp_table = ddl_Element.TaggedValues.GetByName("Temporary Table");
		
		if(temp_table !=  null && temp_table.Value == "True")
			source_commands += "Temporary ";
		
		source_commands += "Table ["+ddl_Element.Name+"]\n";
		
		if(ddl_Element.Attributes.Count != 0 || ddl_Element.Methods.Count != 0)
			source_commands += "("  + "\n" ;
		
		source_commands += getColumnDefintion(ddl_Element,columns); // to get Table Columns and its properties 		
		
		var constraint_and_params = getConstraintAndParams(ddl_Element,constraints,fk_connector,reference_table); // to get constraint and its properties	

		source_commands += constraint_and_params[0];
		index += constraint_and_params[1];
		
		if(ddl_Element.Attributes.Count != 0 || ddl_Element.Methods.Count != 0)
			source_commands +=  "\n)\n"   ;	
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [source_commands,index];	
}

function getColumnDefintion(ddl_Element,columns)
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
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if (NotNull)
				source_commands += "Not Null ";
			
			var col_compression as EA.TaggedValue;
			col_compression = columns.TaggedValues.GetByName("Compression");
			
			if(col_compression != null && col_compression.Value == "True")
				source_commands += "With Compression ";		
				
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

function getConstraintAndParams(ddl_Element,constraints,fk_connector,reference_table)
{
	var source_commands = "";
	var index = "";
	
	try
	{
		for(var k=0 ; k<ddl_Element.Methods.Count ; k++ )// To get the column constraints from the given table element
		{
			constraints = ddl_Element.Methods.GetAt(k);
			
			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "index")
			{
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					source_commands+= "," +"\n";
					
					if(constraints.Name == "")						
						source_commands += "primary key (" ; 	
					else
					source_commands +=  "Constraint ["+constraints.Name+"] primary key (" ; 	
					
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					source_commands+= "," +"\n";
					
					if(constraints.Name == "")	
						source_commands += "foreign key (";
					else 
						source_commands +=  "Constraint ["+constraints.Name+"] foreign key (" ; 
					
				}
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					source_commands += "," +"\n";
					if(constraints.Name == "")						
						source_commands += "unique (";
					else
						source_commands +=  "Constraint ["+constraints.Name+"] unique (" ; 
				}
				else if(constraints.Stereotype == "index") // if the constraints was index
				{
					index += "Create " ;
					
					var is_unique as EA.TaggedValue;
					is_unique = constraints.TaggedValues.GetByName("Unique");
					
					if(is_unique != null)
					{
						if(is_unique.Value == "1" || is_unique == "TRUE")
							index += "Unique ";
					}
					
					index +=  "Index [" + constraints.Name + "] On ["+ddl_Element.Name+"]\n"; 
					
					if(constraints.Parameters.Count != 0)
						index += "(";					
				}				
				
				for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
				{
					constraints_value = constraints.Parameters.GetAt(l);
					
					if(l>0)
					{
						if(index != "" && constraints.Stereotype == "index")
							index += ",";	
						else
							source_commands += ','; 						
					}
					
					if(index != "" && constraints.Stereotype == "index")
						index += "["+constraints_value.Name+"]";
					else
						source_commands += "["+constraints_value.Name+"]";		
				}
				
				if(index != "" && constraints.Stereotype == "index")
				{
					if(constraints.Parameters.Count != 0)	
						index += ") \n";	
					
					var index_option as EA.TaggedValue;
					index_option = constraints.TaggedValues.GetByName("Index Option");
					
					if(index_option != null && index_option.Value != "" && index_option.Value != "<none>")
						index += "With "+index_option.Value+"\n";
					
				}
				else
					source_commands += ") ";
				
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "MsAccess::FK" connector
					source_commands += getForeignKeyReference(ddl_Element,fk_connector,reference_table,constraints); 				
			}	
		}		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return [source_commands,index];
}

function getForeignKeyReference(ddl_Element,fk_connector,reference_table,constraints)
{
	var source_commands = "";
	
	try
	{
		for(var f=0 ; f<ddl_Element.Connectors.Count ; f++)
		{
			fk_connector = ddl_Element.Connectors.GetAt(f);

			if(fk_connector.FQStereotype == "MsAccess::FK" && fk_connector.ClientEnd.Role == constraints.Name)
			{
				var col_ref as EA.Method;
				
				reference_table = Repository.GetElementByID(fk_connector.SupplierID);

				source_commands += "References ["+reference_table.Name+"] ";
				
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

function getViewElements(ddl_Element)
{
	var source_commands = "";
	
	try
	{
		source_commands = "Create View ["+ddl_Element.Name+"]\n" ;
		
		var view_columns as EA.TaggedValue;
		view_columns = ddl_Element.TaggedValues.GetByName("View Columns");
		
		if(view_columns != null && view_columns.Notes != "")
			source_commands += "( " +view_columns.Notes+ " )\n";
		
		var view_def as EA.TaggedValue;
		view_def = ddl_Element.TaggedValues.GetByName("viewdef");
		
		if(view_def !=  null && view_def.Notes != "")
			source_commands += "As "+view_def.Notes+"\n";		
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
	
	var source_commands= "" ;
	
	try
	{
		
		source_commands = "Create Procedure ["+ddl_Element.Name+"]\n" ;
		
		var parameter as EA.TaggedValue;
		parameter = ddl_Element.TaggedValues.GetByName("Parameters");
		
		if(parameter != null && parameter.Notes != "")
			source_commands += "( " +parameter.Notes+ " )\n";
		
		var proc_def as EA.TaggedValue;
		proc_def = ddl_Element.TaggedValues.GetByName("procdef");
		
		if(proc_def != null && proc_def.Notes != "")
			source_commands += "As " +proc_def.Notes+ "\n";		
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return source_commands;	
	
}
!INC Local Scripts.EAConstants-JScript

/* 
  This script is applied for Redshift database only
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
		
		if(ddl_Element.FQStereotype == "Redshift::table") // if the given element was table 
			source_commands += create_table_command(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table);
		else if(ddl_Element.FQStereotype == "Redshift::view") // if the given element was view 
			source_commands = create_view_command(ddl_Element);
		else if(ddl_Element.FQStereotype == "Redshift::procedure") // if the given element was procedure 
			source_commands = create_procd_command(ddl_Element);
		else if(ddl_Element.FQStereotype == "Redshift::function") // if the given element was function 
			source_commands = create_func_command(ddl_Element);		
		
		source_commands += ";";	
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
	try
	{
		var index = "";
		
		source_commands="Create ";
		
		var islocal as EA.TaggedValue;
		islocal = ddl_Element.TaggedValues.GetByName("isLocal");
		
		if(islocal != null  && islocal.Value == "True" )
			source_commands += "local ";
		
		var istem as EA.TaggedValue;
		istem = ddl_Element.TaggedValues.GetByName("isTemporary");
		
		if( istem != null && istem.Value == "True" )
			source_commands += " temporary ";
		
		var isexternal as EA.TaggedValue;
		isexternal = ddl_Element.TaggedValues.GetByName("Is External");	
		
		if(isexternal != null  && isexternal.Value == "True" )
			source_commands += "external ";
		
			source_commands += "table ";	// To write the Create table Command if table type is none or others 
		
		var not_exist as EA.TaggedValue; // To check if the table element have Not Exist property
		not_exist = ddl_Element.TaggedValues.GetByName("Not Exists"); 
		
		if(not_exist != null && not_exist.Value == "True") 
				source_commands += "If Not Exists ";

		var fq_table_name as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		fq_table_name = ddl_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_table_name != null && fq_table_name.Value != "")
		{
			if(fq_table_name.Value.endsWith("."))
				source_commands += fq_table_name.Value;
			else
				source_commands += "\""+fq_table_name.Value+"\"." ;
		}
		source_commands += "\""+ddl_Element.Name +"\"\n";		
		
			source_commands += create_like_table(ddl_Element)

		if(ddl_Element.Attributes.Count != 0)
			source_commands += "("  + "\n" ;			

		source_commands += create_column_command(ddl_Element);
		var commands=[];
		commands= create_method_command(ddl_Element,constraints,constraints_value,fk_connector,reference_table);
		source_commands += commands[0];
		index += commands[1];		

		if(ddl_Element.Attributes.Count != 0)
		{
			source_commands +=  "\n)\n"   ;	
		}
		
		source_commands += table_add_properties(ddl_Element,index,isexternal);
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return source_commands;
}

function create_like_table(table_Elemnets)
{
	var  source_commands="";
	
	try
	{
		var like_connector as EA.Connector; // To include the Like table command from the "Redshift::like" Connector
		var like_table as EA.Element; // Target element of which is connected wiht "Redshift::like" Connector	
		
		for(var l=0 ; l<table_Elemnets.Connectors.Count; l++)
		{
			like_connector = table_Elemnets.Connectors.GetAt(l);
			
			if(like_connector.FQStereotype == "Redshift::like" && table_Elemnets.ElementID == like_connector.ClientID)
			{
				like_table = Repository.GetElementByID(like_connector.SupplierID);				
				source_commands += "( Like \"" + like_table.Name+ "\" )" ;
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

function create_column_command(table_Elements)
{
	var column_command="";
	
	try
	{
		for(var j=0 ; j<table_Elements.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = table_Elements.Attributes.GetAt(j);
			column_command += "\""+columns.Name + "\" " + columns.Type+" "; 
			
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
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
			if (NotNull)
				column_command += "Not Null ";
			
			// To include additional commands from the "Redshift::column" Tagged values in source_commands
			
			var default_value = columns.Default;
		
			if(default_value != "")
				column_command += "Default "+default_value+" ";
			
			var id as EA.TaggedValue;
			id = columns.TaggedValues.GetByName("Identity");
		
			if(id != null && id.Value != "")
				column_command += "Identity "+id.Value+" ";
			
			var default_id as EA.TaggedValue;
			default_id = columns.TaggedValues.GetByName("Default Identity");
		
			if(default_id != null && default_id.Value != "")
				column_command += "Generated by Default As Identity "+default_id.Value+" ";
			
			var encode as EA.TaggedValue;
			encode = columns.TaggedValues.GetByName("Encode");
		
			if(encode != null && encode.Value != "")
				column_command += "Encode "+encode.Value+" ";
			
			var col_distkey as EA.TaggedValue;
			col_distkey = columns.TaggedValues.GetByName("Distkey");
		
			if(col_distkey != null && col_distkey.Value == "True")
				column_command += "Distkey ";
			
			var col_sortkey as EA.TaggedValue;
			col_sortkey = columns.TaggedValues.GetByName("Sortkey");
		
			if(col_sortkey != null && col_sortkey.Value == "True")
				column_command += "Sortkey ";
			
			var collate as EA.TaggedValue;
			collate = columns.TaggedValues.GetByName("Collate");
		
			if(collate != null && collate.Value != "")
				column_command += "Collate "+collate.Value+" ";			
			
			if(j != table_Elements.Attributes.Count - 1)
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

function create_method_command(ddl_Element,constraints,constraints_value,fk_connector,reference_table)
{
	var method_commands=[];
	try
	{
		var index = "";
		var source_commands="";
	
		for(var k=0 ; k<ddl_Element.Methods.Count ; k++ ) // To get the column constraints from the given table element
		{			
			constraints = ddl_Element.Methods.GetAt(k);
			
			if(constraints.Parameters.Count != 0)
			{			
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{	
					source_commands+= "," +"\n";		
						source_commands += "primary key (" ; 	
					
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					source_commands+= "," +"\n";
					
						source_commands += "foreign key (";
					
				}
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					source_commands += "," +"\n";
									
						source_commands += "unique (";
					
				}
				else if(constraints.Stereotype == "index") // if the constraints was index
				{	
					
					var sortkeyType as EA.TaggedValue;
					sortkeyType = constraints.TaggedValues.GetByName("Sortkey Type");
					
					if(sortkeyType != null && sortkeyType.Value != "")
						index += sortkeyType.Value+" ";
					
					var indexType as EA.TaggedValue;
					indexType = constraints.TaggedValues.GetByName("Index Type");
					
					if(indexType != null )
					{
						if(indexType.Value == "Distkey" || indexType.Value == "")
							index += " DistKey (";
						else if(indexType.Value == "Sortkey")
							index += " Sortkey (";	
					}
					
				}
				
				for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names using Method Parmeter
				{
					constraints_value = constraints.Parameters.GetAt(l);
					if(l>0)
					{
						if(constraints.Stereotype == "index")
							index += ",";
						else
							source_commands += ','; 			
					}
					
					if(constraints.Stereotype == "index")
							index += "\""+constraints_value.Name+"\"";			
					else
						source_commands+= "\""+constraints_value.Name+"\"";					
				}	
				
				if(constraints.Stereotype == "index")
					index += ")";		
				else
					source_commands += ") ";		
				
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "Redshift::FK" connector
				{
					for(var f=0 ; f<ddl_Element.Connectors.Count ; f++)
					{
						fk_connector = ddl_Element.Connectors.GetAt(f);

						if(fk_connector.FQStereotype == "Redshift::FK" && fk_connector.ClientEnd.Role == constraints.Name)
						{
							var col_ref as EA.Method;
							
							reference_table = Repository.GetElementByID(fk_connector.SupplierID);

							source_commands += "References \""+reference_table.Name+"\" ";
							
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
									
									ref_column_names += "\""+constraints_value.Name+"\"";
								}

								source_commands += "("+ref_column_names+")";
							}
						}	
					}
				}
			}							
		}
		
		method_commands[0]=source_commands;
		method_commands[1]=index;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
		return method_commands;
}

function table_add_properties(ddl_Element,index,isexternal)
{
	var source_commands="";
	
	try
	{
		// To include additional commands from the "Redshift::table" Tagged values in source_commands
		
		var partition_by as EA.TaggedValue;
		partition_by = ddl_Element.TaggedValues.GetByName("Partitioned By");
		
		if(partition_by != null && partition_by.Value != "" && isexternal.Value == "True"&& isexternal!=null)
			source_commands += "Partitioned By ( "+partition_by.Value+" )\n"; 

		var row_delimeted as EA.TaggedValue;
		row_delimeted = ddl_Element.TaggedValues.GetByName("Row Format Delimited");
		
		if(row_delimeted != null && row_delimeted.Value != ""&& isexternal.Value == "True" && isexternal!=null)
			source_commands += "Row Format Delimited " + row_delimeted.Value+ "\n";
		
		var row_serde as EA.TaggedValue;
		row_serde = ddl_Element.TaggedValues.GetByName("Row Format Serde");
		
		if(row_serde != null && row_serde.Value != ""&& isexternal.Value == "True" && isexternal!=null)
			source_commands += "Row Format Serde " + row_serde.Value+ "\n";
		
		var withSerde as EA.TaggedValue;
		withSerde = ddl_Element.TaggedValues.GetByName("With SerdeProperties");		
		
		if(withSerde != null && withSerde.Notes != ""&& isexternal.Value == "True"&& isexternal!=null)			
			source_commands += "With SerdeProperties ("+ withSerde.Notes + ")\n";	
		
		var stored_as as EA.TaggedValue;
			stored_as = ddl_Element.TaggedValues.GetByName("Stored As");
		
		if(stored_as != null && stored_as.Value != "" && isexternal.Value == "True" && isexternal!=null)
		{
			if(stored_as.Value == "Format Options")
			{
				var input_format as EA.TaggedValue;
				input_format = ddl_Element.TaggedValues.GetByName("Input Format");
				
				var output_format as EA.TaggedValue;
				output_format = ddl_Element.TaggedValues.GetByName("Output Format");
				
				if(input_format!=null && input_format.Value!="")
					source_commands += "Stored As "+"INPUTFORMAT "+input_format.Value+" \n"; 
				
				if(output_format!=null && output_format.Value!="")
					source_commands += "OUTPUTFORMAT "+output_format.Value+" \n"; 
			}
			else 
			{
				source_commands += "Stored As "+stored_as.Value+" \n"; 
			}
		}
		
		var location as EA.TaggedValue;
		location = ddl_Element.TaggedValues.GetByName("Location");
		
		if(location != null && location.Value != ""&& isexternal.Value == "True" && isexternal!=null)
			source_commands += "Location "+location.Value+"\n";
		
		var table_properties as EA.TaggedValue;
		table_properties = ddl_Element.TaggedValues.GetByName("Table Properties");		
		
		if(table_properties != null && table_properties.Notes != ""&& isexternal.Value == "True" && isexternal!=null)			
			source_commands += "Table Properties ("+ table_properties.Notes+")\n";	
		
		var backup as EA.TaggedValue;
		backup = ddl_Element.TaggedValues.GetByName("Backup");
		
		if(backup != null && backup.Value != ""	&& isexternal.Value != "True")
			source_commands += "Backup "+backup.Value+"\n";		
		
		var diststyle as EA.TaggedValue;
		diststyle = ddl_Element.TaggedValues.GetByName("Diststyle");
		
		if(diststyle != null && diststyle.Value != ""&& isexternal.Value != "True")
			source_commands += "Diststyle "+diststyle.Value+"\n";
		
		if(index != "" && isexternal.Value != "True")
				source_commands += index + "\n";	
		
		var sortKey_auto as EA.TaggedValue;
		sortKey_auto = ddl_Element.TaggedValues.GetByName("Sortkey Auto");
		
		if(sortKey_auto != null && sortKey_auto.Value == "True"&& isexternal.Value != "True")
			source_commands += "Sortkey Auto\n";
		
		var encode_auto as EA.TaggedValue;
		encode_auto = ddl_Element.TaggedValues.GetByName("Encode Auto");		
		
		if(encode_auto != null && encode_auto.Value == "True"&& isexternal.Value != "True")
			source_commands += "Encode Auto\n";

		var select_query as EA.TaggedValue;
		select_query = ddl_Element.TaggedValues.GetByName("Select Query");		
		
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

function create_view_command(view_element)
{
	var view_command = "";
	
	try
	{	
		var fq_table_name as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		fq_table_name = view_element.TaggedValues.GetByName("Schema and Database");
		
		var view_type as EA.TaggedValue;
		view_type = view_element.TaggedValues.GetByName("View Type"); // To get View Type tag from MDG to initiate the Create view Command
		
		if(view_type != null && view_type.Value == "Materialized")	
		{
			if(fq_table_name != null && fq_table_name.Value != "")
			{
				if(fq_table_name.Value.endsWith("."))
				view_command +="Create Materialized View " + fq_table_name.Value + "\""+view_element.Name+"\" ";
				else
				view_command +="Create Materialized View \"" + fq_table_name.Value + "\".\""+view_element.Name+"\" ";
			}
			else
			{
				view_command += "Create Materialized View \""+ view_element.Name+ "\" ";
			}
			
		}
		else if(view_type != null && view_type.Value == "Replace")
		{
			if(fq_table_name != null && fq_table_name.Value != "")
			{
				if(fq_table_name.Value.endsWith("."))
					view_command +="Create Or Replace View  " + fq_table_name.Value +"\""+ view_element.Name+"\" ";
				else
					view_command +="Create Or Replace View  \"" + fq_table_name.Value +"\".\""+ view_element.Name+"\" ";
			
			}
			else			
			view_command += "Create Or Replace View \""+ view_element.Name+ "\" ";	
		}
		else if(view_type != null && view_type.Value == "External")
		{
			if(fq_table_name != null && fq_table_name.Value != "")
			{
				if(fq_table_name.Value.endsWith("."))
					view_command +="Create External Protected View  " + fq_table_name.Value+"\"" + view_element.Name+"\" ";
				else
					view_command +="Create External Protected View  \"" + fq_table_name.Value +"\".\""+ view_element.Name+"\" ";
			}
			else
			{
				view_command += "Create External Protected View \""+view_element.Name+"\" ";
			}
			
			
		}
		else 
		{
			view_command += "Create View \""+ view_element.Name+ "\" "; // To write the Create view Command if View type is none or others 
		}
		
		var Not_exits as EA.TaggedValue;
		Not_exits = view_element.TaggedValues.GetByName("Not Exists");		

		if(Not_exits != null && Not_exits.Value == "True")			
			view_command += Not_exits.Value+"\n";
		
		// To include additional commands from the "Redshift::view" Tagged values in view_command

		var columns as EA.TaggedValue;
		columns = view_element.TaggedValues.GetByName("Columns");		

		if(columns != null && columns.Notes != "")			
			view_command += "(" + columns.Notes + ")\n";

		var backup as EA.TaggedValue;
		backup = view_element.TaggedValues.GetByName("Backup");

		if(backup != null && backup.Value != "")
			view_command += "Backup "+backup.Value+"\n";	

		var diststyle as EA.TaggedValue;
		diststyle = view_element.TaggedValues.GetByName("Diststyle");

		if(diststyle != null && diststyle.Value != "")
			view_command += "Diststyle "+diststyle.Value+"\n";

		var sortKey_auto as EA.TaggedValue;
			sortKey_auto = view_element.TaggedValues.GetByName("Sortkey Auto");

		if(sortKey_auto != null && sortKey_auto.Value == "True")
			view_command += "Sortkey Auto\n";

		var encode_auto as EA.TaggedValue;
		encode_auto = view_element.TaggedValues.GetByName("Encode Auto");		

		if(encode_auto != null && encode_auto.Value == "True")
			view_command += "Encode Auto\n";

		var auto_refresh as EA.TaggedValue;
		auto_refresh = view_element.TaggedValues.GetByName("Auto Refresh");

		if(auto_refresh != null && auto_refresh.Value != ""&& view_type.Value == "Materialized")
			view_command += "Auto Refresh "+auto_refresh.Value+"\n";	
		var externalviewprop as EA.TaggedValue;
		externalviewprop = view_element.TaggedValues.GetByName("External view Properties");

		if(externalviewprop != null && externalviewprop.Value != ""&& view_type.Value == "External")
			view_command += "Auto Refresh "+auto_refresh.Value+"\n";
		

		var view_def as EA.TaggedValue;
		view_def = view_element.TaggedValues.GetByName("viewdef");		

		if(view_def != null && view_def.Notes != "")			
			view_command += "As "+ view_def.Notes;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return view_command;
}

function create_procd_command(proc_element)
{
	var proc_command = "";
	
	try
	{	
		var fq_table_name as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		fq_table_name = proc_element.TaggedValues.GetByName("Schema and Database");
			
		var replace as EA.TaggedValue;
		    replace = proc_element.TaggedValues.GetByName("Replace"); // To get is replaced or not  from MDG tag to initiate the Create Procedure Command
		
		 if(replace != null && replace.Value == "True")
			proc_command += "Create Or Replace Procedure " ;
		 else
			 proc_command += "Create Procedure " ;
		
		if(fq_table_name != null && fq_table_name.Value != "")
		{
			if(fq_table_name.Value.endsWith("."))
			proc_command += fq_table_name.Value+"\""+proc_element.Name + "\"\n";	
		  else 
			proc_command += "\""+fq_table_name.Value+"\".\""+ proc_element.Name + "\"\n";  // To write the Create Procedure Command if Replace is false or others
		}
		else
			proc_command += "\""+proc_element.Name + "\"\n";
		
		 
		
		// To include additional commands from the "Redshift::procedure" Tagged values in proc_command
		var pro_arguments as EA.TaggedValue;
		pro_arguments = proc_element.TaggedValues.GetByName("Arguments");		
		
		if(pro_arguments != null && pro_arguments.Notes != "")			
			proc_command +=  pro_arguments.Notes + "\n";
		
		var non_atomic as EA.TaggedValue;
		non_atomic = proc_element.TaggedValues.GetByName("NonAtomic");		
		
		if(non_atomic != null && non_atomic.Value == "True")
			proc_command += "NonAtomic\n";
		
		var pro_def as EA.TaggedValue;
		pro_def = proc_element.TaggedValues.GetByName("procdef");		
		
		if(pro_def != null && pro_def.Notes != "")			
			proc_command += "As "+ pro_def.Notes + "\n";
		
		//Adding default Language
			proc_command += "Language plpgsql\n";					
		
		var security as EA.TaggedValue;
		security = proc_element.TaggedValues.GetByName("Security");
		
		if(security != null && security.Value != "")
			proc_command += "Security "+security.Value+"\n";	
		
		var set_config as EA.TaggedValue;
		set_config = proc_element.TaggedValues.GetByName("Set Configuration");		
		
		if(set_config != null && set_config.Notes != "")			
			proc_command += "Set "+ set_config.Notes + "\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return proc_command;
}

function create_func_command(func_element)
{
	var func_command="";
	
	try
	{
		var fq_table_name as EA.TaggedValue; // To get the fully qualified table name from "Schema and Database" tagged value
		fq_table_name = func_element.TaggedValues.GetByName("Schema and Database");
		
		var replace as EA.TaggedValue;
		replace = func_element.TaggedValues.GetByName("Replace");

		var external as EA.TaggedValue;
		external = func_element.TaggedValues.GetByName("External");	
			// To get is replaced and external from MDG tag to initiate the Create Function Command	
		
		if(external != null && replace != null && replace.Value == "True" && external.Value == "True" )
			func_command += "Create Or Replace External Function ";
		else if(replace != null && replace.Value == "True")
			func_command += "Create Or Replace Function " ;	
		else if(external != null && external.Value == "True" )
			func_command += "Create External Function " ;	
		else
			func_command += "Create Function " ;	// To write the Create Function Command if Replace & External is false or others
		
			
		if(fq_table_name != null && fq_table_name.Value != "")
		{
			if(fq_table_name.Value.endsWith("."))
				func_command += fq_table_name.Value+func_element.Name+ " \n";
			else
				func_command += "\""+fq_table_name.Value+"\".\""+func_element.Name+ "\" \n";
		}
		else
			func_command += "\""+func_element.Name+ "\" \n";		
		
		// To include additional commands from the "Redshift::function" Tagged values in func_command
		var func_arguments as EA.TaggedValue;
		func_arguments = func_element.TaggedValues.GetByName("Arguments");		
		
		if(func_arguments != null && func_arguments.Notes != "")			
			func_command +=  func_arguments.Notes + "\n";
		
		var return_type as EA.TaggedValue;
		return_type = func_element.TaggedValues.GetByName("Return");
		
		if(return_type != null && return_type.Value != "")
			func_command += "Returns "+return_type.Value+  "\n";
		
		var volatility_category as EA.TaggedValue;
		volatility_category = func_element.TaggedValues.GetByName("Volatility Category");
		
		if(volatility_category != null && volatility_category.Value != "")
			func_command += volatility_category.Value+  "\n";
		
		var func_def as EA.TaggedValue;
		func_def = func_element.TaggedValues.GetByName("funcdef");		
		
		if(func_def != null && func_def.Notes != "")			
			func_command += "As "+ func_def.Notes + "\n";
		
		var language as EA.TaggedValue;
		language = func_element.TaggedValues.GetByName("Function Language");
		
		if(language != null && language.Value != "")
			func_command += "Language "+language.Value+  "\n";
		
		var lambda as EA.TaggedValue;
		lambda = func_element.TaggedValues.GetByName("Lambda");
		
		if(lambda != null && lambda.Value != "")
			func_command += "Lambda "+lambda.Value+  "\n";
		
		var sagemaker as EA.TaggedValue;
		sagemaker = func_element.TaggedValues.GetByName("Sagemaker");
		
		if(sagemaker != null && sagemaker.Value != "")
			func_command += "Sagemaker "+sagemaker.Value+  "\n";
		
		var im_role as EA.TaggedValue;
		im_role = func_element.TaggedValues.GetByName("Iam Role");
		
		if(im_role != null && im_role.Value != "")
			func_command += "Iam_Role "+im_role.Value+  "\n";
		
		var retry_timeout as EA.TaggedValue;
		retry_timeout = func_element.TaggedValues.GetByName("Retry Timeout");
		
		if(retry_timeout != null && retry_timeout.Value != "")
			func_command += "Retry_Timeout "+retry_timeout.Value+  "\n";
		
		var max_batch_rows as EA.TaggedValue;
		max_batch_rows = func_element.TaggedValues.GetByName("Max Batch Rows");
		
		if(max_batch_rows != null && max_batch_rows.Value != "")
			func_command += "Max_Batch_Rows "+max_batch_rows.Value+  "\n";
		
		var max_batch_size as EA.TaggedValue;
		max_batch_size = func_element.TaggedValues.GetByName("Max Batch Size");
		
		if(max_batch_size != null && max_batch_size.Value != "")
			func_command += "Max_Batch_Size "+max_batch_size.Value+  "\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
		return func_command;
}

!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for SQL Server database only
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
		source_command = "";
		if(ddl_Element.FQStereotype == "SqlServer::table") // if the given element was table 
		{
			var commands=[];
			commands = create_table_command(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table);
			source_commands = commands[0];
			index = commands[1];
			trigger = commands[2];
		}
		else if(ddl_Element.FQStereotype == "SqlServer::view") // if the given element was view 
			source_commands = create_view_command(ddl_Element);
		else if(ddl_Element.FQStereotype == "SqlServer::function")
			source_commands = create_function_command(ddl_Element);
		else if(ddl_Element.FQStereotype == "SqlServer::procedure")
			source_commands = create_proce_command(ddl_Element);	
		else if(ddl_Element.FQStereotype == "SqlServer::sequence")
			source_commands = create_seq_command(ddl_Element);
			
		if(source_commands != "")
			source_commands += ";\nGO";	
		
		if(index != "" )
			source_commands += "\n"+index+"GO\n";
		else if(trigger != "")
			source_commands += "\n"+trigger+"GO\n";
		
		source_Filepath.WriteLine(source_commands + "\n");
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
}

function create_table_command(table_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table)
{
	
	var create_command=[];
	try
	{
	
		source_commands = "Create ";
		var index="";
		var trigger="";

		var is_external as EA.TaggedValue;
		is_external = table_Element.TaggedValues.GetByName("Is External");
		
		if(is_external != null && is_external.Value == "True")
			source_commands += "External ";
		
		source_commands +=  "Table ";
		
		var fq_table_name as EA.TaggedValue;
		fq_table_name = table_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_table_name != null && fq_table_name.Value != "")
		{
			var fqtable=""
			fqtable += create_schema_name(fq_table_name )
			if(!fqtable.endsWith("."))
				source_commands += fqtable+".";
			else
				source_commands += fqtable;
		}
		source_commands += "["+table_Element.Name+"]\n";
		
		var is_filetable as EA.TaggedValue;		
		is_filetable = table_Element.TaggedValues.GetByName("Is Filetable");
		
		if(is_filetable != null && is_filetable.Value == "True")
			source_commands += "As FileTable \n";
		
		if(table_Element.Attributes.Count != 0)
			source_commands += "("  + "\n" ;
		
		source_commands += create_column_command(table_Element);

		var method_command=[];
			method_command = create_method_command(table_Element,constraints,constraints_value,fk_connector,reference_table);
		
		source_commands += method_command[0];
		index = method_command[1];
		trigger = method_command[2];
		
		if(table_Element.Attributes.Count != 0)
		{
			var temp_data as EA.TaggedValue;
			temp_data = table_Element.TaggedValues.GetByName("Temporal Data");
			
			if(temp_data != null && temp_data.Notes != "")
				source_commands += ",\nPeriod For System_time ( "+temp_data.Notes+" )\n";
			
			source_commands +=  "\n)\n"   ;	
		}
				
		var graph_type as EA.TaggedValue;		
		graph_type = table_Element.TaggedValues.GetByName("Graph Type");
		
		if(graph_type != null)
		{
			if(graph_type.Value == "Node")
				source_commands += "As Node \n";
			else if(graph_type.Value == "Edge")
				source_commands += "As Edge \n";			
		}
		
		var partition_clause as EA.TaggedValue;		
		partition_clause = table_Element.TaggedValues.GetByName("Partition Clause");
		
		if(partition_clause != null && partition_clause.Notes !="")
			source_commands += "On "+partition_clause.Notes+"\n";
		
		var txt_img_clause as EA.TaggedValue;		
		txt_img_clause = table_Element.TaggedValues.GetByName("Text Image Clause");
		
		if(txt_img_clause != null && txt_img_clause.Value != "")
			source_commands += "TextImage_On "+txt_img_clause.Value+"\n";
		
		var file_stream_clause as EA.TaggedValue;		
		file_stream_clause = table_Element.TaggedValues.GetByName("File Stream Clause");
		
		if(file_stream_clause != null && file_stream_clause.Value != "")
			source_commands += "FileStream_On "+file_stream_clause.Value+"\n";
		
		
		
		//Vis_27112026_[261101149]_WITH clause: HISTORY_TABLE placed right after SYSTEM_VERSIONING = ON and emitted even when Table Option is empty
		var tbl_option as EA.TaggedValue;
		tbl_option = table_Element.TaggedValues.GetByName("Table Option");

		var tbl_opt_text = (tbl_option != null) ? tbl_option.Notes : "";
		var history_clause = getConnectors(table_Element); // "(HISTORY_TABLE = ...)" from the SqlServer::systemversion connector

		if(history_clause != "")
		{
			var sv_regex = /SYSTEM_VERSIONING\s*=\s*ON/i;
			if(sv_regex.test(tbl_opt_text))
				tbl_opt_text = tbl_opt_text.replace(sv_regex, function(m){ return m + " " + history_clause; });
			else
				tbl_opt_text = "SYSTEM_VERSIONING = ON " + history_clause + (tbl_opt_text != "" ? ", " + tbl_opt_text : "");
		}

		if(tbl_opt_text != "")
			source_commands += "With ( " + tbl_opt_text + " )\n";
		var select_query as EA.TaggedValue;		
		select_query = table_Element.TaggedValues.GetByName("Select Query");	
		
		if(select_query != null && select_query.Notes != "")
			source_commands += "As "+select_query.Notes+"\n";
		
		create_command[0] = source_commands;
		create_command[1] = index;
		create_command[2] = trigger;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
		return  create_command;
		
}

function create_column_command(table_Element)
{
	var column_command="";
	try
	{
	
		for(var j=0 ; j<table_Element.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = table_Element.Attributes.GetAt(j);
			column_command += "["+columns.Name + "] ";
			if(columns.Type!="")
				column_command += "[" + columns.Type+"] ";
			
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
			
			var comp_col_expr as EA.TaggedValue;
			comp_col_expr = columns.TaggedValues.GetByName("Computed Column Expression");
			
			if(comp_col_expr != null && comp_col_expr.Notes != "")
				column_command += "As "+comp_col_expr.Notes+" ";
			
			var persisted as EA.TaggedValue;
			persisted = columns.TaggedValues.GetByName("Persisted");
			
			if(persisted != null && persisted.Value == "True")
				column_command += "Persisted " ;
			
			var set_def as EA.TaggedValue;
			set_def = columns.TaggedValues.GetByName("Set Definition");
			
			if(set_def != null && set_def.Value == "True")
				column_command += "Xml Column_Set For All_Sparse_Columns ";	
			
			var file_stream as EA.TaggedValue;
			file_stream = columns.TaggedValues.GetByName("Filestream");
			
			if(file_stream != null && file_stream.Value == "True")
				column_command += "Filestream ";
			
			var collate as EA.TaggedValue;
			collate = columns.TaggedValues.GetByName("Collate");
			
			if(collate != null && collate.Value != "")
				column_command += "Collate "+collate.Value+" ";
			
			var sparse as EA.TaggedValue;
			sparse = columns.TaggedValues.GetByName("Sparse");
			
			if(sparse != null && sparse.Value == "True")
				column_command += "Sparse ";
			
			var masked_func as EA.TaggedValue;
			masked_func = columns.TaggedValues.GetByName("Masked Function");
			
			if(masked_func != null && masked_func.Value != "")
				column_command += "Masked With ( Function = "+masked_func.Value+" ) ";
			
			var identity as EA.TaggedValue;
			identity = columns.TaggedValues.GetByName("Identity");
			
			if(identity != null && identity.Value != "")
				column_command += "Identity "+identity.Value+" ";
			
			var not_for_replication as EA.TaggedValue;
			not_for_replication = columns.TaggedValues.GetByName("Not For Replication");
			
			if(not_for_replication != null && not_for_replication.Value == "True")
				column_command += "Not For Replication ";
			
			var generate_as as EA.TaggedValue;
			generate_as = columns.TaggedValues.GetByName("Generate As");			
			
			if(generate_as != null && generate_as.Value != "")
				column_command += "Generated Always As "+generate_as.Value+" ";
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if(NotNull)
				column_command += "Not Null ";
			
			var row_guid_col as EA.TaggedValue;
			row_guid_col = columns.TaggedValues.GetByName("RowGuidCol");		

			if(row_guid_col != null && row_guid_col.Value == "True")
				column_command += "RowGuidCol ";
			
			var encrypt_with as EA.TaggedValue;
			encrypt_with = columns.TaggedValues.GetByName("Encrypted With");	

			if(encrypt_with != null && encrypt_with.Notes != "")
				column_command += "Encrypted With "+encrypt_with.Notes+" ";
			
			var col_indx as EA.TaggedValue;
			col_indx = columns.TaggedValues.GetByName("Column Index");	
			
			if(col_indx != null && col_indx.Notes != "")
				column_command += col_indx.Notes+ " ";
			
			var def_expr = columns.Default;
			
			if(def_expr != "")
				column_command += "Default "+def_expr+" " ;
			
			if(j != table_Element.Attributes.Count - 1)
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


function create_method_command(table_Element,constraints,constraints_value,fk_connector,reference_table)
{
	var commands=[];
	try
	{
	
		var index_command="";
		var trigger_command="";
		var constraint_command="";
	
		for(var k=0 ; k<table_Element.Methods.Count ; k++ )// To get the column constraints from the given table element
		{
			constraints = table_Element.Methods.GetAt(k);			

			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "index" || constraints.Stereotype == "trigger"||  constraints.Stereotype == "check")
			{
				var index_type as EA.TaggedValue;
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					constraint_command+= "," +"\n";
					
					constraint_command += "primary key (" ; 						
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					constraint_command+= "," +"\n";

						constraint_command += "foreign key (";
				}	
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					constraint_command += "," +"\n";
					constraint_command += "unique (";
				}
				else if(constraints.Stereotype == "check") // if the constraints was check
				{
					constraint_command += "," +"\n";
					
						constraint_command += "Check (";
					
					if(constraints.Code != "")
						constraint_command += constraints.Code ;
					
				}
				else if(constraints.Stereotype == "index") // if the constraints was index
				{
					var is_table_index as EA.TaggedValue;
					is_table_index = constraints.TaggedValues.GetByName("Table Index");
					
					if(is_table_index != null && is_table_index.Value == "True")
					{
						constraint_command += "," +"\n";
						
						constraint_command +=  "Index ["+constraints.Name+"] " ;
						
						var is_unique as EA.TaggedValue;
						is_unique = constraints.TaggedValues.GetByName("Unique");
						
						if(is_unique != null)
						{
							if(is_unique.Value == "1" || is_unique == "TRUE")
								constraint_command += "Unique ";
						}
						
						var is_clustered as EA.TaggedValue;
						is_clustered = constraints.TaggedValues.GetByName("Clustered");
						
						if(is_clustered != null)
						{
							if(is_clustered.Value == "1" || is_clustered == "TRUE")
								constraint_command += "Clustered ";
						}
						
						var columnstore as EA.TaggedValue;
						columnstore = constraints.TaggedValues.GetByName("Is Columnstore");
					
						if(columnstore != null && columnstore.Value == "True")
							constraint_command += "Columnstore ";
						
						constraint_command +="(";
					
					}
					else
					{
						index_command += "Create " ;	
						
						var is_unique as EA.TaggedValue;
						is_unique = constraints.TaggedValues.GetByName("Unique");
						
						if(is_unique != null)
						{
							if(is_unique.Value == "1" || is_unique == "TRUE")
								index_command += "Unique ";
						}
						
						var is_clustered as EA.TaggedValue;
						is_clustered = constraints.TaggedValues.GetByName("Clustered");
						
						if(is_clustered != null)
						{
							if(is_clustered.Value == "1" || is_clustered == "TRUE")
								index_command += "Clustered ";
						}
						
						var columnstore as EA.TaggedValue;
						columnstore = constraints.TaggedValues.GetByName("Is Columnstore");
					
						if(columnstore != null && columnstore.Value == "True")
							index_command += "Columnstore ";

						index_type = constraints.TaggedValues.GetByName("Index Type");
						
						if(index_type != null )
						{
							if(index_type.Value == "Full Text")
								index_command += "FullText ";
							else if(index_type.Value == "Spatial")
								index_command += "Spatial ";
							else if(index_type.Value == "XML")
								index_command += "XML ";
						}
						
						index_command += "index ";

						if(index_type != null && index_type.Value != "Full Text")
							index_command += "["+constraints.Name+"]\n";
						
						index_command += "On ["+table_Element.Name+"]\n";
						
						if(constraints.Parameters.Count != 0)
							index_command += "(";
					}
					
				}
				else if(constraints.Stereotype == "trigger") // if the constraints was trigger
				{
					trigger_command += "Create ";
					
					var is_alter as EA.TaggedValue;
					is_alter = constraints.TaggedValues.GetByName("Is Alter");
					
					if(is_alter != null && is_alter.Value == "True")
						trigger_command += "Is Alter ";
					
					trigger_command += "Trigger ";
					
					var fq_trigger_name as EA.TaggedValue;
					fq_trigger_name = constraints.TaggedValues.GetByName("Schema and Database");
					
					if(fq_trigger_name != null && fq_trigger_name.Value != "")
					{ 
						var fqname="";
						fqname+=create_schema_name(fq_trigger_name )
						if(!fqname.endsWith("."))
							trigger_command += fqname+".";
						else
							trigger_command += fqname;
					}
					trigger_command += "["+constraints.Name+"]\n";
					
					trigger_command += "On ["+table_Element.Name+"]\n" ;
					
					var logon as EA.TaggedValue;
					logon = constraints.TaggedValues.GetByName("Is Logon");
					
					if(logon != null && logon.Value == "True")
						trigger_command += "Logon \n"
					
					var trg_opt as EA.TaggedValue;
					trg_opt = constraints.TaggedValues.GetByName("Trigger Option");
					
					if(trg_opt != null && trg_opt.Notes != "")
						trigger_command += "With "+trg_opt.Notes+"\n";
					
					var trg_time as EA.TaggedValue;
					trg_time = constraints.TaggedValues.GetByName("TRG_TIME");
					
					if(trg_time != null)
					{
						if(trg_time.Value == "Before")
							trigger_command += "For \n";
						else if(trg_time.Value == "After")
							trigger_command += "After \n";
						else if(trg_time.Value == "Instead Of")
							trigger_command += "Instead Of \n";
					}
						
					
					var trg_event as EA.TaggedValue;
					trg_event = constraints.TaggedValues.GetByName("TRG_EVENT");
					
					if(trg_event != null)
					{
						if(trg_event.Value == "Insert or Update or Delete")
							trigger_command += "Insert , Update , Delete \n";
						else if(trg_event.Value == "Insert or Update")
							trigger_command += "Insert , Update \n";
						else if(trg_event.Value == "Insert or Delete")
							trigger_command += "Insert , Delete \n";
						else if(trg_event.Value == "Update or Delete")
							trigger_command += "Update , Delete \n";
						else if(trg_event.Value == "Insert")
							trigger_command += "Insert \n";
						else if(trg_event.Value == "Delete")
							trigger_command += "Delete \n";
						else if(trg_event.Value == "Update")
							trigger_command += "Update \n";
					}

					var append as EA.TaggedValue;
					append = constraints.TaggedValues.GetByName("With Append");
					
					if(append != null && append.Value == "True")
						trigger_command += "With Append \n";
					
					var not_for_replication as EA.TaggedValue;
					not_for_replication = constraints.TaggedValues.GetByName("Not For Replication");
					
					if(not_for_replication != null && not_for_replication.Value == "True")
						trigger_command += "Not For Replication \n";
					
					if(constraints.Code != "")
						trigger_command += "As "+constraints.Code+"\n";		

					trigger_command += "; \n\n";
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
						index_command += constraints_value.Name;	
					else if(trigger_command != "" && constraints.Stereotype == "trigger")
						trigger_command += constraints_value.Name;	
					else
						constraint_command+= constraints_value.Name;		
				}
				
				if(index_command != "" && constraints.Stereotype == "index")
				{
					if(constraints.Parameters.Count != 0)
						index_command += ")\n";	
					
					if(index_type != null && index_type.Value == "Full Text")
						index_command += "Key Index "+constraints.Name+"\n";
					
					var include as EA.TaggedValue;
					include = constraints.TaggedValues.GetByName("Include");
					
					if(include != null && include.Notes != "")
						index_command += "Include ("+include.Notes+" )\n";
					
					var tesselation_type as EA.TaggedValue;
					tesselation_type = constraints.TaggedValues.GetByName("Tessellation Type");
					
					if(tesselation_type != null)
					{
						if(tesselation_type.Value == "Geography Auto Grid")
							index_command += "Using Geography_Auto_Grid \n";
						else if(tesselation_type.Value == "Geometry Grid")
							index_command += "Using Geometry_Grid \n";
						else if(tesselation_type.Value == "Geometry Auto Grid")
							index_command += "Using Geometry_Auto_Grid \n";
						else if(tesselation_type.Value == "Geography Grid")
							index_command += "Using Geography_Grid \n";
					}
					
					
					var for_index as EA.TaggedValue;
					for_index = constraints.TaggedValues.GetByName("Index For");
					
					if(for_index != null && for_index.Notes != "")
						index_command +=  "For ( "+for_index.Notes+" )\n" ;
					
					var indx_option as EA.TaggedValue;
					indx_option = constraints.TaggedValues.GetByName("Index Option");
					
					if(indx_option != null && indx_option.Notes != "")
						index_command += "With ( "+indx_option.Notes+" )\n" ;
					
					var on_val as EA.TaggedValue;
					on_val = constraints.TaggedValues.GetByName("On Value");
					
					if(on_val != null && on_val.Value != "")
						index_command +="On "+on_val.Value+"\n" ;	
					
					var where_condition as EA.TaggedValue;
					where_condition = constraints.TaggedValues.GetByName("Where Condition");
					
					if(where_condition != null && where_condition.Notes != "")
						index_command += "Where "+where_condition.Notes+"\n" ;
					
					var filestream as EA.TaggedValue;
					filestream = constraints.TaggedValues.GetByName("Filestream On");
					
					if(filestream != null  && filestream.Value != "")
						index_command += "Filestream_On "+filestream.Value+"\n" ;
					
					var order_by as EA.TaggedValue;
					order_by = constraints.TaggedValues.GetByName("Order By");
					
					if(order_by != null && order_by.Notes != "")
						index_command += "Order ( " +order_by.Notes+ " )\n";
					
					index_command += ";\n\n";
				}
				else if(index_command == "" && constraints.Stereotype == "index")
				{
					if(constraints.Parameters.Count != 0)
						constraint_command += ")\n";	
					
					var indx_option as EA.TaggedValue;
					indx_option = constraints.TaggedValues.GetByName("Index Option");
					
					if(indx_option != null && indx_option.Notes != "")
						constraint_command += "With ( "+indx_option.Notes+" )\n" ;
					
					var include as EA.TaggedValue;
					include = constraints.TaggedValues.GetByName("Include");
					
					if(include != null && include.Notes != "")
						constraint_command += "Include ("+include.Notes+" )\n";
					
					var where_condition as EA.TaggedValue;
					where_condition = constraints.TaggedValues.GetByName("Where Condition");
					
					if(where_condition != null && where_condition.Notes != "")
						constraint_command += "Where "+where_condition.Notes+"\n" ;
					
					var on_val as EA.TaggedValue;
					on_val = constraints.TaggedValues.GetByName("On Value");
					
					if(on_val != null && on_val.Value != "")
						constraint_command +="On "+on_val.Value+"\n" ;
					
					var filestream as EA.TaggedValue;
					filestream = constraints.TaggedValues.GetByName("Filestream On");
					
					if(filestream != null && filestream.Value != "")
						constraint_command += "Filestream_On "+filestream.Value+"\n" ;
					
					var order_by as EA.TaggedValue;
					order_by = constraints.TaggedValues.GetByName("Order By");
					
					if(order_by != null && order_by.Notes != "")
						constraint_command += "Order ( " +order_by.Notes+ " )\n";
					
					var where_condition as EA.TaggedValue;
					where_condition = constraints.TaggedValues.GetByName("Where Condition");
					
					if(where_condition != null && where_condition.Notes != "")
						constraint_command += "Where "+where_condition.Notes+"\n" ;
					
				}
				else if(trigger_command != "" && constraints.Stereotype == "trigger")
				{
					if(constraints.Parameters.Count != 0)
						trigger_command += ")\n"
				}
				else
					constraint_command += ") ";	
				
				if(constraints.Stereotype == "PK"||constraints.Stereotype == "unique")
				{
					var Constraint_Option as EA.TaggedValue;
					Constraint_Option = constraints.TaggedValues.GetByName("Constrain Option");
					if(Constraint_Option!=null&&Constraint_Option.Notes!="")
					{
						constraint_command += "With "+Constraint_Option.Notes
					}
				}

				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "SqlServer::FK" connector
				{
					for(var f=0 ; f<table_Element.Connectors.Count ; f++)
					{
						fk_connector = table_Element.Connectors.GetAt(f);

						if(fk_connector.FQStereotype == "SqlServer::FK" && fk_connector.ClientEnd.Role == constraints.Name)
						{
							var col_ref as EA.Method;

							reference_table = Repository.GetElementByID(fk_connector.SupplierID);
							
							var ref_data_schema as EA.TaggedValue;
							ref_data_schema = reference_table.TaggedValues.GetByName("Schema and Database");						
							if(ref_data_schema!=null&&ref_data_schema.Value!="")
							{
								var refname="";
								refname +=create_schema_name(ref_data_schema )
								if(!refname.endsWith("."))
								{
									constraint_command += "References " +refname + ".["+ reference_table.Name+"] ";
								}
								else
									constraint_command += "References " +refname+ "["+ reference_table.Name+"] ";
							}
							else
								constraint_command += "References " + "["+ reference_table.Name+"] ";

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
		return commands;
}

function create_view_command(view_element)
{
	
	var view_commands = "Create ";
	try
	{
		
		var is_alter as EA.TaggedValue;
		is_alter = view_element.TaggedValues.GetByName("Is Alter");
		
		if(is_alter != null && is_alter.Value == "True")
			view_commands += "Alter ";
		
		view_commands += "View ";
		
		var fq_view_name as EA.TaggedValue;
		fq_view_name = view_element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_view_name != null && fq_view_name.Value != "")
		{
			var fqname="";
			fqname += create_schema_name(fq_view_name )
			if(!fqname.endsWith("."))
				view_commands += fqname+".";
			else
				view_commands += fqname;
		}
		
		view_commands += "["+view_element.Name+"]\n";
		
		var view_col as EA.TaggedValue;
		view_col = view_element.TaggedValues.GetByName("View Columns");
		
		if(view_col != null && view_col.Notes != "")
			view_commands += "( "+view_col.Notes+" )\n";
		
		var view_attr as EA.TaggedValue;
		view_attr = view_element.TaggedValues.GetByName("View Attribute");
		
		if(view_attr != null && (view_attr.Value != "<none>" && view_attr.Value != ""))
			view_commands += "With "+view_attr.Value+" \n";
		
		var view_def as EA.TaggedValue;
		view_def = view_element.TaggedValues.GetByName("viewdef");
		
		if(view_def != null && view_def.Notes != "")
			view_commands += "As "+view_def.Notes+"\n";
		
		var with_check as EA.TaggedValue;
		with_check = view_element.TaggedValues.GetByName("With Check");
		
		if(with_check != null && with_check.Value == "True")
			view_commands += "With Check Option \n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
		
		return view_commands;
}

function create_function_command(func_element)
{
	var func_commands = "Create ";
	
	try
	{
		var is_alter as EA.TaggedValue;
		is_alter = func_element.TaggedValues.GetByName("Is Alter");
		
		if(is_alter != null && is_alter.Value == "True")
			func_commands += "Alter ";
		
		func_commands += "Function ";
		
		var fq_func_name as EA.TaggedValue;
		fq_func_name = func_element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_func_name != null && fq_func_name.Value != "")
		{
			var FQfunc_name=""
			FQfunc_name+= create_schema_name(fq_func_name )
			if(!FQfunc_name.endsWith("."))
			{
				func_commands += FQfunc_name+".";
			}
			else
				func_commands += FQfunc_name;
		}
		
		func_commands += "["+func_element.Name+"]\n";
		
		var func_param as EA.TaggedValue;
		func_param = func_element.TaggedValues.GetByName("Function Parameters");
		
		if(func_param != null && func_param.Notes != "")
			func_commands += "( "+func_param.Notes+" )\n" ;
		
		var returns as EA.TaggedValue;
		returns = func_element.TaggedValues.GetByName("Returns");
		
		if(returns != null && returns.Notes != "")
			func_commands += "Returns "+returns.Notes+"\n";			
		
		var func_opt as EA.TaggedValue;
		func_opt = func_element.TaggedValues.GetByName("Function Option");
		
		if(func_opt != null && func_opt.Notes != "")
			func_commands += "With "+func_opt.Notes+"\n";
		
		var order_clause as EA.TaggedValue;
		order_clause =  func_element.TaggedValues.GetByName("Order Clause");
		
		if(order_clause != null && order_clause.Notes != "")
			func_commands += "Order ( " +order_clause.Notes+ " )\n";
		
		var func_def as EA.TaggedValue;
		func_def = func_element.TaggedValues.GetByName("funcdef");
		
		if(func_def != null && func_def.Notes != "")
			func_commands += "As "+func_def.Notes+"\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
		return func_commands;
}


function create_proce_command(proce_Element)
{
	
	var proce_command = "Create ";
	try
	{
		
		var is_alter as EA.TaggedValue;
		is_alter = proce_Element.TaggedValues.GetByName("Is Alter");
		
		if(is_alter != null && is_alter.Value == "True")
			proce_command += "Alter ";
		
		proce_command += "Procedure ";
		
		var fq_proc_name as EA.TaggedValue;
		fq_proc_name = proce_Element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_proc_name != null && fq_proc_name.Value != "")
		{
			var fqproc_name="";
			fqproc_name+= create_schema_name(fq_proc_name )
			if(!fqproc_name.endsWith("."))
			{
				proce_command += fqproc_name+".";
			}
			else
				proce_command += fqproc_name;
		}
		
		proce_command += "["+proce_Element.Name+"]\n";
		
		var proc_param as EA.TaggedValue;
		proc_param =  proce_Element.TaggedValues.GetByName("Procedure Parameters");
		
		if(proc_param != null && proc_param.Notes != "")
			proce_command += proc_param.Notes +"\n";
		
		var proc_opt as EA.TaggedValue;
		proc_opt =  proce_Element.TaggedValues.GetByName("Procedure Option");
		
		if(proc_opt != null && proc_opt.Notes != "")
			proce_command += proc_opt.Notes +"\n";
		
		var for_replication as EA.TaggedValue;
		for_replication = proce_Element.TaggedValues.GetByName("For Replication");
		
		if(for_replication != null && for_replication.Value == "True")
			proce_command += "For Replication \n";
		
		var proc_def as EA.TaggedValue;
		proc_def = proce_Element.TaggedValues.GetByName("procdef");
		
		if(proc_def != null && proc_def.Notes != "")
			proce_command += "As "+proc_def.Notes+"\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
		return proce_command;
}

function getConnectors(ddl_Element)
{
	var source_commands = "";
	try
	{
		var table_con as EA.Connector;
		var connected_table as EA.Element;
		for(var l=0 ; l<ddl_Element.Connectors.Count; l++)  // To include the Like table command from the Connectors list
		{
			table_con = ddl_Element.Connectors.GetAt(l);
			
			if(ddl_Element.ElementID == table_con.ClientID)
			{
				connected_table = Repository.GetElementByID(table_con.SupplierID);	
				
				if(table_con.FQStereotype == "SqlServer::systemversion")	
				{
					source_commands += "\n(HISTORY_TABLE = ";
					//Vis_27112026_[261101149]_History table schema now built with create_schema_name() like other object names
					var schema_name as EA.TaggedValue;
					schema_name = connected_table.TaggedValues.GetByName("Schema and Database");

					if(schema_name != null && schema_name.Value != "")
					{
						var hist_schema = create_schema_name(schema_name);
						if(hist_schema.endsWith("."))
							source_commands += hist_schema;
						else
							source_commands += hist_schema+".";
					}
					source_commands +=  "["+ connected_table.Name + "]\n)";
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

function create_seq_command(seq_element)
{
	var seq_command = "Create Sequence ";
	try
	{
		
		var fq_seq_name as EA.TaggedValue;
		fq_seq_name = seq_element.TaggedValues.GetByName("Schema and Database");
		
		if(fq_seq_name != null && fq_seq_name.Value != "")
		{
			var fqseq_name ="";
			fqseq_name+= create_schema_name(fq_seq_name )
			if(!fqseq_name.endsWith("."))
			{
				seq_command += fqseq_name+".";
			}
			else
				seq_command += fqseq_name;
		}
		
		
		seq_command += "["+seq_element.Name+"]\n";
		
		var type_sepc as EA.TaggedValue;
		type_sepc =  seq_element.TaggedValues.GetByName("Data Type Specification");
		
		if(type_sepc != null && type_sepc.Value != "")
			seq_command += "As "+type_sepc.Value+"\n";	
		
		var Start_with as EA.TaggedValue;
		Start_with = seq_element.TaggedValues.GetByName("Start With");
		
		if(Start_with != null && Start_with.Value != "")
			seq_command += "Start With "+Start_with.Value+"\n";	
		
		var Increment_by as EA.TaggedValue;
		Increment_by = seq_element.TaggedValues.GetByName("Increment By");
		
		if(Increment_by != null && Increment_by.Value != "")
			seq_command += "Increment By "+Increment_by.Value+"\n";	
		
		var min_val_spec as EA.TaggedValue;
		min_val_spec = seq_element.TaggedValues.GetByName("MinValue Specification");
		
		if(min_val_spec != null)
		{
			if(min_val_spec.Value == "Yes")
			{
				seq_command += "MinValue \n" ;
				
				var min_value as EA.TaggedValue;
				min_value = seq_element.TaggedValues.GetByName("MinValue");
				
				if(min_value != null && min_value.Value != "")
					seq_command += min_value.Value + "\n";				
				
			}
			else if(min_val_spec.Value == "No")
				seq_command += "No MinValue \n" ;
		}
		
		var max_val_spec as EA.TaggedValue;
		max_val_spec = seq_element.TaggedValues.GetByName("MaxValue Specification");
		
		if(max_val_spec != null)
		{
			if(max_val_spec.Value == "Yes")
			{
				seq_command += "MaxValue \n";
				
				var max_value as EA.TaggedValue;				
				max_value = seq_element.TaggedValues.GetByName("MaxValue");
				
				if(max_value != null && max_value.Value != "")
					seq_command += max_value.Value + "\n";						
			}
			else if(max_val_spec.Value == "No")
				seq_command += "No MaxValue \n";
		}
		
		var cir_seq as EA.TaggedValue;
		cir_seq = seq_element.TaggedValues.GetByName("Circular Sequence");
		
		if(cir_seq != null)
		{
			if(cir_seq.Value == "Yes")
				seq_command += "Cycle \n";
			else if(cir_seq.Value == "No")
				seq_command += "No Cycle \n";
		}
		var caching as EA.TaggedValue;
		caching = seq_element.TaggedValues.GetByName("Caching");
		
		if(caching != null)
		{
			if(caching.Value == "Yes")
			{
				seq_command += "Cache \n";
				
				var cache_value as EA.TaggedValue;				
				cache_value = seq_element.TaggedValues.GetByName("Cache Value");
				
				if(cache_value != null && cache_value.Value != "")
					seq_command += cache_value.Value + "\n";		
				
			}
			else if(caching.Value == "No")
				seq_command += "No Cache \n";
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return seq_command;
}

function create_schema_name(fq_table_name )
{
	var schema_name ="";
	schema_name=fq_table_name.Value;
	var name="";
	var slipt_name=schema_name.split(".")
	for(var i=0;i<slipt_name.length;i++)
	{
		var str=""
		str=slipt_name[i];
		str=str.replace("[","")
		str=str.replace("]","")
		if(i==slipt_name.length-1)
		{
			if(str!="")
			{
			name+="["+str+"]"
			}
		}
		else
			name+="["+str+"].";
	}
	return name;
}
!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for Oracle database only
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
		
		if(ddl_Element.FQStereotype == "Oracle::table") // if the given element was table 
		{
			var create_command=[];
			create_command=Create_table_command(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table);
			if(create_command[0] !=undefined)
				source_commands=create_command[0];
			if(create_command[1] != undefined)
				index = create_command[1];
			if(create_command[2] != undefined)
				trigger = create_command[2];
			
		}
		else if(ddl_Element.FQStereotype == "Oracle::view") // if the given element was view 
			source_commands = create_view_command(ddl_Element);
		else if(ddl_Element.FQStereotype == "Oracle::sequence")
			source_commands=create_seq_command(ddl_Element);		
		else if(ddl_Element.FQStereotype == "Oracle::function")
			source_commands = create_func_commands(ddl_Element);
		else if(ddl_Element.FQStereotype == "Oracle::procedure")
			source_commands = create_procedure_command(ddl_Element);		
				
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
function Create_table_command(ddl_Element,source_commands,columns,constraints,constraints_value,source_Filepath,fk_connector,reference_table)
{
	var commands=[];
	try
	{
		var index = "";
		var trigger = "";
		
		source_commands = "Create ";
			
		var table_type as EA.TaggedValue;
		table_type = ddl_Element.TaggedValues.GetByName("Table Type");
		
		if(table_type != null && table_type.Value != "<none>" && table_type.Value != "")
			source_commands += table_type.Value + " ";
		
		source_commands += "Table ";
		
		var db_schema as EA.TaggedValue;
		db_schema = ddl_Element.TaggedValues.GetByName("Database and Schema");
		
		if(db_schema != null && db_schema.Value != "")
		{
			if(db_schema.Value.endsWith("."))
			source_commands += "\""+db_schema.Value+"\"";
			else
				source_commands += "\""+db_schema.Value+"\".";
			
		}
		source_commands +=  "\""+ddl_Element.Name +"\"\n";
				
		
		var sharing_clause as EA.TaggedValue;
		sharing_clause = ddl_Element.TaggedValues.GetByName("Sharing Clause");
		
		if(sharing_clause != null && sharing_clause.Value !="")
			source_commands += "Sharing = "+sharing_clause.Value+"\n";
		
		
		var table_format as EA.TaggedValue;
		table_format = ddl_Element.TaggedValues.GetByName("Table Formats");
		
		if(table_format != null)
		{
			if(table_format.Value == "XmlType")
				source_commands += "Of XmlType \n";					
			else if(table_format.Value == "Object")
				source_commands += "Of \n";	
		}
		
		var obj_type as EA.TaggedValue;
		obj_type = ddl_Element.TaggedValues.GetByName("Object Type");
		
		if(obj_type != null && obj_type.Value != "")
			source_commands += obj_type.Value + "\n";
		
		var tab_subst as EA.TaggedValue;
		tab_subst = ddl_Element.TaggedValues.GetByName("Table Substitution");
		
		if(tab_subst != null)
		{
			if(tab_subst.Value == "Yes")
				source_commands += "Substitutable At All Levels \n";
			else if(tab_subst.Value == "No")
				source_commands += "Not Substitutable At All Levels \n";
		}
		
		if(ddl_Element.Attributes.Count != 0)
			source_commands += "("  + "\n" ;
		for(var j=0 ; j<ddl_Element.Attributes.Count ; j++) // To get the columns from the given table element
		{
			columns = ddl_Element.Attributes.GetAt(j);
			source_commands += create_column_command(ddl_Element,columns);
			if(j != ddl_Element.Attributes.Count - 1)
				source_commands += ","+ "\n";
		}
		 
		
		 var create_commands=[];
		create_commands = create_method_command(ddl_Element,constraints,constraints_value,fk_connector,reference_table);
		if(create_commands[0]!=undefined)
			source_commands += create_commands[0];
		if(create_commands[1]!=undefined)
			index += create_commands[1];
		if(create_commands[2]!=undefined)
			trigger += create_commands[2];
		 
		if(ddl_Element.Attributes.Count != 0)
		{
			var Outer_Ref_Constraint as EA.TaggedValue;
			Outer_Ref_Constraint = columns.TaggedValues.GetByName("Outline Reference Constraint");
			
			if(Outer_Ref_Constraint != null && Outer_Ref_Constraint.Notes != "")
			{
				source_commands += Outer_Ref_Constraint.Notes+" ";
			}
					
			source_commands +=  "\n)\n"   ;	
		}		

			source_commands += table_add_properties(ddl_Element);

		commands[0]=source_commands;
		commands[1]=index;
		commands[2]=trigger;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return commands;
		
		
}

function create_column_command(table_element,columns)
{
	var column_Command="";
	try
	{
			column_Command += "\""+columns.Name + "\" " + columns.Type+" ";
			
			if(columns.Length != 0 || columns.Precision != 0)
			{
				if(columns.Length != 0)
					column_Command += "("+columns.Length;
				else if(columns.Precision != 0)
					column_Command += "("+columns.Precision;
				
				if(columns.Scale != 0)
					column_Command += ","+columns.Scale;
				
				column_Command +=") ";
			}
			
			var collate as EA.TaggedValue;
			collate = columns.TaggedValues.GetByName("Collation");
			
			if(collate != null && collate.Value != "")
				column_Command += "Collate "+collate.Value+" ";
			
			var sort as EA.TaggedValue;
			sort = columns.TaggedValues.GetByName("Sorted Index");
			
			if(sort != null && sort.Value == "True")
				column_Command += "Sort ";
			
			var visible_spec as EA.TaggedValue;
			visible_spec = columns.TaggedValues.GetByName("Visibility Specification");
			
			if(visible_spec != null && visible_spec.Value != "<none>"  && visible_spec.Value != "")
				column_Command += visible_spec.Value+" ";
			
			var col_int as EA.TaggedValue;
			col_int = columns.TaggedValues.GetByName("Column Initialization");
			
			if(col_int != null && col_int.Notes != "")
				column_Command += col_int.Notes+" ";
			
			var encrypt as EA.TaggedValue;
			encrypt = columns.TaggedValues.GetByName("Encrypt Specification");
			
			if(encrypt != null && encrypt.Notes != "")
				column_Command += "Encrypt "+encrypt.Notes+" ";
			
			var auto_generate as EA.TaggedValue;
			auto_generate = columns.TaggedValues.GetByName("Automatic Generation");
			
			if(auto_generate != null && auto_generate.Value == "True")
				column_Command += "Generated Always AS ";
			
			var column_Expression as EA.TaggedValue;
			column_Expression = columns.TaggedValues.GetByName("Column Expression");
			
			if(column_Expression !=null && column_Expression.Notes !="" )
				column_Command += "("+column_Expression.Notes+") ";
			
			var is_virtual as EA.TaggedValue;
			is_virtual = columns.TaggedValues.GetByName("Virtual");
			
			if(is_virtual != null && is_virtual.Value == "True")
				column_Command += "Virtual ";
			
			var evaluation as EA.TaggedValue;
			evaluation = columns.TaggedValues.GetByName("Evaluation Edition");
			
			if(evaluation != null && evaluation.Value != "")
				column_Command += "Evaluate Using "+evaluation.Value+" ";
			
			var unusable as EA.TaggedValue;
			unusable = columns.TaggedValues.GetByName("Unusable Edition");
			
			if(unusable != null && unusable.Value != "")
				column_Command += unusable.Value+" ";
			
			var NotNull = columns.AllowDuplicates; // to check if the not null checkbox is checked or not in Column properties 
				
			if (NotNull)
				column_Command += "Not Null ";
			
			
			var def_expr as EA.TaggedValue;
			def_expr = columns.Default;
			
			if(def_expr != "")
				column_Command += "Default "+def_expr+" ";
			
			var inline_ref_constraint as EA.TaggedValue;
			inline_ref_constraint = columns.TaggedValues.GetByName("Inline Reference Constraint");
			
			if(inline_ref_constraint != null && inline_ref_constraint.Notes != "")
				column_Command += inline_ref_constraint.Notes+" ";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
	return column_Command;
}

function create_method_command(table_Elements,constraints,constraints_value,fk_connector,reference_table)
{
	var comands=[];
	try
	{		
		var index_command="";
		var trigger_command="";
		var constraint_command="";
		for(var k=0 ; k<table_Elements.Methods.Count ; k++ )// To get the column constraints from the given table element
		{
			constraints = table_Elements.Methods.GetAt(k);
			
			var trg_event_value = "";
			var trg_constr = "";
						
			if(constraints.Parameters.Count != 0 || constraints.Stereotype == "index" || constraints.Stereotype == "trigger" || constraints.Stereotype == "check")
			{				
				if(constraints.Stereotype == "PK") // if the constraints was primary key
				{
					constraint_command+= "," +"\n";
					
					if(constraints.Name == "")						
						constraint_command += "primary key (" ; 	
					else
						constraint_command +=  "Constraint "+constraints.Name+" primary key (" ; 					
				}
				else if(constraints.Stereotype == "FK") // if the constraints was foreign key
				{
					constraint_command+= "," +"\n";
					
					if(constraints.Name == "")	
						constraint_command += "foreign key (";
					else 
						constraint_command +=  "Constraint "+constraints.Name+" foreign key (" ; 
				}	
				else if(constraints.Stereotype == "unique") // if the constraints was unique
				{
					constraint_command += "," +"\n";
					if(constraints.Name == "")						
						constraint_command += "unique (";
					else
						constraint_command +=  "Constraint "+constraints.Name+" unique (" ; 
				}
				else if(constraints.Stereotype == "check") // if the constraints was check
				{
					constraint_command += "," +"\n";
					
					if(constraints.Name == "")	
						constraint_command += "Check (";
					else
						constraint_command +=  "Constraint "+constraints.Name+" Check (";
					
					if(constraints.Code != "")
						constraint_command += constraints.Code  ;
					
				}
				else if(constraints.Stereotype == "index") // if the constraints was index
				{
					index_command += "Create " ;	
					
					var index_type as EA.TaggedValue;
					index_type = constraints.TaggedValues.GetByName("Index Type");
					
					if(index_type != null && index_type.Value != "<none>" && index_type.Value != "") 
						index_command += index_type.Value+" ";					
					
					index_command += "Index ";		

					var db_schema as EA.TaggedValue;
					db_schema = table_Elements.TaggedValues.GetByName("Database and Schema");
					
					if(db_schema != null && db_schema.Value != "")
					{
						if(db_schema.Value.endsWith("."))
						index_command += "\""+db_schema.Value+"\"";
						else
							index_command += "\""+db_schema.Value+"\".";
						
					}					
					
					index_command += "\""+constraints.Name+ "\"\n";
					
					var ilm_cluase as EA.TaggedValue;
					ilm_cluase = constraints.TaggedValues.GetByName("ILM Cluase");
					
					if(ilm_cluase != null && ilm_cluase.Notes != "")
						index_command += "ILM ( "+ilm_cluase.Notes+" )\n";
					
					index_command += "On \n";
					
					var index_format as EA.TaggedValue;
					index_format = constraints.TaggedValues.GetByName("Index Format");		
					
					if(index_format != null && index_format.Value == "Cluster")
						index_command += "Cluster ";
					
					var table_schema as EA.TaggedValue;
					table_schema = constraints.TaggedValues.GetByName("Table Schema");	
					
					if(table_schema != null && table_schema.Value != "")
					{
						if(table_schema.Value.endsWith("."))
						index_command += "\""+table_schema.Value+"\"";
						else
							index_command += "\""+table_schema.Value+"\".";
						
					}		
					index_command += table_Elements.Name + "\n";				
				
					if(constraints.Parameters.Count != 0)
						index_command += "("; 
					
				}
				else if(constraints.Stereotype == "trigger") // if the constraints was trigger
				{
					trigger_command += "Create ";
					
					var is_replace as EA.TaggedValue;
					is_replace = table_Elements.TaggedValues.GetByName("Is Replace");

					if(is_replace != null && is_replace.Value == "True")
						trigger_command += "Or Replace ";
					
					var trg_type as EA.TaggedValue;
					trg_type = table_Elements.TaggedValues.GetByName("Trigger Type");

					if(trg_type != null )
					{
						if(trg_type.Value == "Editionable")
							trigger_command += "Editionable ";
						else if(trg_type.Value == "Non Editionable")
							trigger_command += "NonEditionable ";
					}	
					
					trigger_command += "Trigger ";
					
						var db_schema as EA.TaggedValue;
					db_schema = table_Elements.TaggedValues.GetByName("Database and Schema");
					
					if(db_schema != null && db_schema.Value != "")
					{
						if(db_schema.Value.endsWith("."))
						trigger_command +="\""+ db_schema.Value+"\"";
						else
							trigger_command += "\""+db_schema.Value+"\".";
						
					}		
					
					trigger_command +=  "\""+constraints.Name+"\"\n";
					
					var sharing_clause as EA.TaggedValue;
					sharing_clause = table_Elements.TaggedValues.GetByName("Sharing Clause");

					if(sharing_clause != null && sharing_clause.Value !="")
						trigger_command += "Sharing = "+sharing_clause.Value+"\n";		
					
					var default_collation as EA.TaggedValue;
					default_collation = table_Elements.TaggedValues.GetByName("Default Collation");

					if(default_collation != null && default_collation.Value == "True")
						trigger_command += "Default Collation USING_NLS_COMP \n";
					
					var trg_time as EA.TaggedValue;
					trg_time = constraints.TaggedValues.GetByName("TRG_TIME");
					
					if(trg_time != null)
					{
						if(trg_time.Value == "Before")
							trigger_command += "Before \n";
						else if(trg_time.Value == "After")
							trigger_command += "After \n";
					}
					
					var trg_event as EA.TaggedValue;
					trg_event = constraints.TaggedValues.GetByName("TRG_EVENT");
					
					if(trg_event != null && trg_event.Value != "")
						trg_event_value +=  trg_event.Value +"\n";										
				}
				
				for(var l=0 ; l<constraints.Parameters.Count ; l++ ) // to get constraints column names
				{
					constraints_value = constraints.Parameters.GetAt(l);
					
					if(l>0)
					{
						if(index_command != "" && constraints.Stereotype == "index")
							index_command += ",";	
						else if(constraints.Stereotype == "trigger")
							trg_constr += ",";	
						else
							constraint_command += ','; 
						
					}
					
					if(index_command != "" && constraints.Stereotype == "index")
						index_command += "\""+constraints_value.Name+"\"";
					else if(constraints.Stereotype == "trigger")
						trg_constr += "\""+constraints_value.Name+"\"" ;
					else
						constraint_command += "\""+constraints_value.Name+"\"";	
				}
							
				
				if(index_command != "" && constraints.Stereotype == "index")
				{
					if(constraints.Parameters.Count != 0)	
						index_command += ") \n";		
					
					var idx_expr as EA.TaggedValue;
					idx_expr = constraints.TaggedValues.GetByName("Index Expression");	
					
					if(idx_expr != null && idx_expr.Notes != "")
						index_command += "( "+idx_expr.Notes + " )\n";
					
					var idx_prop as EA.TaggedValue;
					idx_prop = constraints.TaggedValues.GetByName("Index Properties");	
					
					if(idx_prop != null && idx_prop.Notes != "")
						index_command += idx_prop.Notes + " \n";
					
					var bitmap_from as EA.TaggedValue;
					bitmap_from = constraints.TaggedValues.GetByName("Bitmap From");	
					
					if(bitmap_from != null && bitmap_from.Notes != "")
						index_command += "From "+bitmap_from.Notes+"\n";
					
					var where_condition as EA.TaggedValue;
					where_condition = constraints.TaggedValues.GetByName("Where Condition");	
					
					if(where_condition != null && where_condition.Notes != "")
						index_command += "Where "+where_condition.Notes+"\n";
					
					var local_partitioned as EA.TaggedValue;
					local_partitioned = constraints.TaggedValues.GetByName("Local Partitioned");	
					
					if(local_partitioned != null && local_partitioned.Notes != "")
						index_command += local_partitioned.Notes+"\n"; 
					
					var idx_attr as EA.TaggedValue;
					idx_attr = constraints.TaggedValues.GetByName("Index Attributes");	
					
					if(idx_attr != null && idx_attr.Notes != "")
						index_command += idx_attr.Notes + "\n";			

					var index_status as EA.TaggedValue;
					index_status = constraints.TaggedValues.GetByName("Index Status");	
					
					if(index_status != null && index_status.Value != "<none>" && index_status.Value != "")
						index_command += index_status.Value+"\n";
					
					var invalidation as EA.TaggedValue;
					invalidation = constraints.TaggedValues.GetByName("Invalidation");	
					
					if(invalidation != null && invalidation.Value != "" && invalidation.Value != "<none>")
						index_command += invalidation.Value+"\n";
					
					index_command += "; \n\n";
				}
				else if(trigger_command != "" && constraints.Stereotype == "trigger")
				{					
					if(trg_event_value != "")
					{
						if (trg_event_value.includes("Update") && trg_constr !="") 
							trigger_command += trg_event_value.replace("Update", "Update Of " + trg_constr);							
						else
							trigger_command +=trg_event_value;						
					}	
						trigger_command += " On ";
					var trigger_table_schema as EA.TaggedValue;
					trigger_table_schema = table_Elements.TaggedValues.GetByName("Database and Schema");
					
					if(trigger_table_schema != null && trigger_table_schema.Value != "")
					{
						if(trigger_table_schema.Value.endsWith("."))
							trigger_command += "\""+trigger_table_schema.Value+"\"";
						else
							trigger_command += "\""+trigger_table_schema.Value+"\".";
						
					}
					
					trigger_command += "\""+table_Elements.Name+ "\"\n";
					
					var ref_clause as EA.TaggedValue;
					ref_clause = constraints.TaggedValues.GetByName("Referencing Clause");	
					
					if(ref_clause != null && ref_clause.Notes != "")
						trigger_command += ref_clause.Notes+"\n";
					
					var for_each_row as EA.TaggedValue;
					for_each_row = constraints.TaggedValues.GetByName("For Each Row");	
					
					if(for_each_row != null && for_each_row.Value == "True")
						trigger_command += "For Each Row \n";
					
					var trg_edition as EA.TaggedValue;
					trg_edition = constraints.TaggedValues.GetByName("Trigger Edition");	
					
					if(trg_edition != null && trg_edition.Value != "<none>" && trg_edition.Value != "" )
						trigger_command += trg_edition.Value+" CrossEdition \n";
					
					var trg_order as EA.TaggedValue;
					trg_order = constraints.TaggedValues.GetByName("Trigger Ordering");	
					
					if(trg_order != null && trg_order.Notes != "" )
						trigger_command += trg_edition.Notes+"\n";
					
					var trg_status as EA.TaggedValue;
					trg_status = constraints.TaggedValues.GetByName("Trigger Status");	
					
					if(trg_status != null && trg_status.Value != "<none>" && trg_status.Value != "" )
						trigger_command += trg_status.Value+"\n";
					
					var search_condition as EA.TaggedValue;
					search_condition = constraints.TaggedValues.GetByName("Search Condition");	
					
					if(search_condition != null && search_condition.Notes != "" )
						trigger_command += "When ( "+search_condition.Notes+" )\n";
					
					if(constraints.Code != "")
						trigger_command += constraints.Code+"\n";	
					
					trigger_command += "; \n\n";
					
				}
				else
				{
					constraint_command += ") ";
				}
				
				if(constraints.Stereotype == "FK") // To get the Refence table with column fromt the "Oracle::FK" connector
				{
					for(var f=0 ; f<table_Elements.Connectors.Count ; f++)
					{
						fk_connector = table_Elements.Connectors.GetAt(f);

						if(fk_connector.FQStereotype == "Oracle::FK" && fk_connector.ClientEnd.Role == constraints.Name)
						{
							var col_ref as EA.Method;
							
							reference_table = Repository.GetElementByID(fk_connector.SupplierID);
							constraint_command += "References "
							var ref_table_schema as EA.TaggedValue;
								ref_table_schema = reference_table.TaggedValues.GetByName("Database and Schema");
								
								if(ref_table_schema != null && ref_table_schema.Value != "")
								{
									if(ref_table_schema.Value.endsWith("."))
									constraint_command += "\""+ref_table_schema.Value+"\"";
									else
										constraint_command += "\""+ref_table_schema.Value+"\".";
									
								}
								constraint_command +=  "\""+reference_table.Name +"\"\n";
							
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
					
					var on_delete as EA.TaggedValue;
					on_delete = constraints.TaggedValues.GetByName("Delete");
					
					if(on_delete != null && on_delete.Value != "")
						constraint_command += "On Delete " +on_delete.Value+" ";	
				}				
			}			
		}
		comands[0]=constraint_command;
		comands[1]=index_command;
		comands[2]=trigger_command;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return comands;
}

function table_add_properties(table_element)
{
	var source_commands="";
	try
	{
		var immutable as EA.TaggedValue;
		immutable = table_element.TaggedValues.GetByName("Immutable Table");
		
		if(immutable != null && immutable.Notes != "")
			source_commands += immutable.Notes + "\n";
		
		var collate as EA.TaggedValue;
		collate = table_element.TaggedValues.GetByName("Collation");
		
		if(collate != null && collate.Value != "")
			source_commands += "Default Collate "+collate.Value+"\n";
		
		var on_commit_def as EA.TaggedValue;
		on_commit_def = table_element.TaggedValues.GetByName("On Commit Definition");
		
		if(on_commit_def != null)
		{
			if(on_commit_def.Value == "Drop")
				source_commands += "On Commit Drop Definition\n";
			else if(on_commit_def.Value == "Preserve")
				source_commands += "On Commit Preserve Definition\n";			
		}
		
		
		var on_commit_row as EA.TaggedValue;
		on_commit_row = table_element.TaggedValues.GetByName("On Commit Rows");
		
		if(on_commit_row != null)
		{
			if(on_commit_row.Value == "Delete")
				source_commands += "On Commit Delete Rows \n";
			else if(on_commit_row.Value == "Preserve")
				source_commands += "On Commit Preserve Rows\n";			
		}		
		
		var xml_type_storage as EA.TaggedValue;
		xml_type_storage = table_element.TaggedValues.GetByName("XMLType Storage");
		
		if(xml_type_storage != null && xml_type_storage.Notes != "")
			source_commands +=  "XmlType "+xml_type_storage.Notes+" \n"   ;		

		var xml_schema_spec as EA.TaggedValue;
		xml_schema_spec = table_element.TaggedValues.GetByName("XMLSchema Spec");
		
		if(xml_schema_spec != null && xml_schema_spec.Notes != "")
			source_commands +=  xml_schema_spec.Notes+" \n"   ;		
		
		var xml_Vcolumn as EA.TaggedValue;
		xml_Vcolumn = table_element.TaggedValues.GetByName("XMLType Virtual Columns");
		
		if(xml_Vcolumn != null && xml_Vcolumn.Notes != "")
			source_commands +=  xml_Vcolumn.Notes+" \n"   ;	
		
		var oid_clause as EA.TaggedValue;
		oid_clause  = table_element.TaggedValues.GetByName("Object Identifier");
		
		if(oid_clause != null && oid_clause.Value != "<none>" && oid_clause.Value != "")
			source_commands += "Object Identifier Is "+oid_clause.Value+" \n";
		
		var oid_index as EA.TaggedValue;
		oid_index = table_element.TaggedValues.GetByName("OID Index");
		
		if(oid_index != null && oid_index.Notes != "")
			source_commands += oid_index.Notes + "\n";
		
		var physical_properties as EA.TaggedValue;
		physical_properties = table_element.TaggedValues.GetByName("Physical Properties");
		
		if(physical_properties !=  null && physical_properties.Notes != "")
			source_commands += physical_properties.Notes + "\n";
		
		var opaque_type as EA.TaggedValue;
		opaque_type = table_element.TaggedValues.GetByName("Opaque Type");
		
		if(opaque_type !=  null && opaque_type.Notes != "")
			source_commands += opaque_type.Notes + "\n";
		
		
		var column_properties as EA.TaggedValue;
		column_properties = table_element.TaggedValues.GetByName("Column Properties");
		
		if(column_properties !=  null && column_properties.Notes != "")
			source_commands += column_properties.Notes + "\n";
		
		
		var read_only_clause as EA.TaggedValue;
		read_only_clause  = table_element.TaggedValues.GetByName("Read Only Clause");
		
		if(read_only_clause != null && read_only_clause.Value != "<none>" && read_only_clause.Value != "")
			source_commands +=  read_only_clause.Value+" \n";
		
		var indexing as EA.TaggedValue;
		indexing = table_element.TaggedValues.GetByName("Indexing");
		
		if(indexing != null && indexing.Value != "<none>" && indexing.Value != "")
			source_commands +=  "Indexing "+indexing.Value+" \n";
		
		var table_partition as EA.TaggedValue;
		table_partition =  table_element.TaggedValues.GetByName("Table Partition");
		
		if(table_partition != null && table_partition.Notes != "")
			source_commands += table_partition.Notes+"\n";	
		
		var cache_option as EA.TaggedValue;
		cache_option = table_element.TaggedValues.GetByName("Caching Option");
		
		if(cache_option != null)
		{	
			if(cache_option.Value == "Cache")
				source_commands += "Cache ";
			else if(cache_option.Value == "No Cache")
				source_commands += "NoCache \n";			
		}		
		
		var result_cache as EA.TaggedValue;
		result_cache = table_element.TaggedValues.GetByName("Result Cache");
		
		if(result_cache != null && result_cache.Notes !="")
			source_commands += "Result_Cache "+result_cache.Notes+"\n";	
		
		var parallel_clause as EA.TaggedValue;
		parallel_clause = table_element.TaggedValues.GetByName("Parallel Clause");
		
		if(parallel_clause != null)
		{
			if(parallel_clause.Value == "Parallel")
				source_commands += "Parallel \n ";
			else if(parallel_clause.Value == "No Parallel")
				source_commands += "NoParallel \n ";
			
			var parallel_range as EA.TaggedValue;
			parallel_range = table_element.TaggedValues.GetByName("Parallel Range");
		
			if(parallel_range != null && parallel_range.Value !="")
				source_commands += parallel_range.Value+"\n";					
		}
		
		var row_dependencies as EA.TaggedValue;
		row_dependencies = table_element.TaggedValues.GetByName("Row Dependencies");
		
		if(row_dependencies !=  null )
		{
			if(row_dependencies.Value == "Yes")
				source_commands += "Rowdependencies \n";
			else if(row_dependencies.Value == "No")
				source_commands += "NoRowdependencies \n";			
		}
		
		
		var enable_disable as EA.TaggedValue;
		enable_disable = table_element.TaggedValues.GetByName("Enable Disable Clause");
		
		if(enable_disable != null && enable_disable.Notes != "")
			source_commands += enable_disable.Notes+"\n";
		
		var row_moment as EA.TaggedValue;
		row_moment = table_element.TaggedValues.GetByName("Row Movement");
		
		if(row_moment != null && row_moment.Value != "" && row_moment.Value != "<none>")
			source_commands += row_moment.Value +" Row Movement \n";
		
		var logical_replication as EA.TaggedValue;
		logical_replication = table_element.TaggedValues.GetByName("Logical Replication");
		
		if(logical_replication != null && logical_replication.Value != "")
			source_commands += logical_replication.Value + "\n";
		
		var flasback_acrhive as EA.TaggedValue;
		flasback_acrhive = table_element.TaggedValues.GetByName("Flashback Archive");
		
		if(flasback_acrhive != null)
		{
			if(flasback_acrhive.Value == "Yes")
				source_commands += "Flashback \n" ;
			else if(flasback_acrhive.Value == "No")
				source_commands += "No Flashback \n" ;
			
			var flashback_archive_value as EA.TaggedValue;
			flashback_archive_value = table_element.TaggedValues.GetByName("Flashback Archive Value");
			
			if(flashback_archive_value != null && flashback_archive_value.Value != "")
				source_commands += flashback_archive_value.Value +"\n" ;			
		}
		
		var row_archival as EA.TaggedValue;
		row_archival = table_element.TaggedValues.GetByName("Row Archival");
		
		if(row_archival != null && row_archival.Value == "True")
			source_commands += "Row Archival \n" ;	
		
		var select_query as EA.TaggedValue;
		select_query = table_element.TaggedValues.GetByName("Select Query");
		
		if(select_query != null && select_query.Notes != "")
			source_commands += "As "+select_query.Notes + "\n";
		
		var exchange_with as EA.TaggedValue;
		exchange_with = table_element.TaggedValues.GetByName("Exchange with");
		
		if(exchange_with != null && exchange_with.Value != "")
			source_commands += "For Exchage With Table "+exchange_with.Value+" \n";
		
		
		var for_read as EA.TaggedValue;
		for_read = table_element.TaggedValues.GetByName("For Read");
		
		if(for_read != null && for_read.Value == "True")
			source_commands += "MemOptimize For Read \n";
		
		var for_write as EA.TaggedValue;
		for_write = table_element.TaggedValues.GetByName("For Write");		
		
		if(for_write != null && for_write.Value == "True")
			source_commands += "MemOptimize For Write \n";
		
		var parent_value as EA.TaggedValue;
		parent_value = table_element.TaggedValues.GetByName("Parent");	
		
		if(parent_value !=  null && parent_value.Value != "")
			source_commands += "Parent "+parent_value.Value+"\n";
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return source_commands;
}

function create_view_command(view_Element)
{
	var view_commands = "Create ";
	try
	{
		var is_replace as EA.TaggedValue;
		is_replace = view_Element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			view_commands += "Or Replace ";
		
		var force as EA.TaggedValue;
		force =  view_Element.TaggedValues.GetByName("Force");
		
		if(force != null)
		{
			if(force.Value == "Yes")
				view_commands += "Force ";
			else if(force.Value == "No")
				view_commands += "No Force ";
		}
		
		var view_type as EA.TaggedValue;
		view_type =  view_Element.TaggedValues.GetByName("View Type");
		
		if(view_type != null)
		{
			if(view_type.Value == "Editioning")
				view_commands += "Editioning ";
			else if(view_type.Value == "Editionable")
				view_commands += "Editionable ";
			else if(view_type.Value == "Editionable Editioning")
				view_commands += "Editionable Editioning ";
			else if(view_type.Value == "Non Editionable")
				view_commands += "NonEditionable ";
			else if(view_type.Value == "Analytic")
				view_commands += "Analytic ";
			else if(view_type.Value == "Materialized")
				view_commands += "Materialized ";			
		}		
		
		view_commands += "View ";
		
		var log_on as EA.TaggedValue;
		log_on = view_Element.TaggedValues.GetByName("Log On");
		
		if(log_on != null && log_on.Value == "True")
			view_commands += "Log On " ;
		
		var db_schema as EA.TaggedValue;
		db_schema = view_Element.TaggedValues.GetByName("Database and Schema");
		
		if(db_schema != null && db_schema.Value != "")
		{
			if(db_schema.Value.endsWith("."))
			view_commands += "\""+db_schema.Value+"\"";
			else
				view_commands += "\""+db_schema.Value+"\".";
			
		}		
		
		view_commands += "\""+view_Element.Name+"\"\n";
		
		var column_spec as EA.TaggedValue;
		column_spec = view_Element.TaggedValues.GetByName("Column Specification");
		
		if(column_spec != null && column_spec.Notes != "")
			view_commands += "( " +column_spec.Notes+" )\n";	
		
		var collate as EA.TaggedValue;
		collate = view_Element.TaggedValues.GetByName("Collation");
		
		if(collate != null && collate.Value != "")
			view_commands += "Default Collate "+collate.Value+"\n";
		
		var prebuilt_table as EA.TaggedValue;
		prebuilt_table =  view_Element.TaggedValues.GetByName("Prebuilt Table");
		
		if(prebuilt_table != null && prebuilt_table.Value == "True")
			view_commands += "On Prebuilt Table \n";
		
		var reduced_precision as EA.TaggedValue;
		reduced_precision =  view_Element.TaggedValues.GetByName("Reduced Precision");
		
		if(reduced_precision != null )
		{
			if(reduced_precision.Value == "Yes")
				view_commands += "With Reduced Precision \n";
			else if(reduced_precision.Value == "No")
				view_commands += "Without Reduced Precision \n";
		}
		
		var physical_properties as EA.TaggedValue;
		physical_properties =  view_Element.TaggedValues.GetByName("Physical Properties");
		
		if(physical_properties != null && physical_properties.Notes != "")
			view_commands += physical_properties.Notes+"\n";		
		
		var column_properties as EA.TaggedValue;
		column_properties =  view_Element.TaggedValues.GetByName("Column Properties");
		
		if(column_properties != null && column_properties.Notes != "")
			view_commands += column_properties.Notes+"\n";	
		
		var table_partition as EA.TaggedValue;
		table_partition =  view_Element.TaggedValues.GetByName("Table Partition");
		
		if(table_partition != null && table_partition.Notes != "")
			view_commands += table_partition.Notes+"\n";	
		
		var cache_option as EA.TaggedValue;
		cache_option = view_Element.TaggedValues.GetByName("Caching Option");
		
		if(cache_option != null)
		{	
			if(cache_option.Value == "Cache")
				view_commands += "Cache ";
			
			var cache_value as EA.TaggedValue;
			cache_value = view_Element.TaggedValues.GetByName("Cache Value");
		
			if(cache_value != null && cache_value.Value !="")
				view_commands += cache_value.Value+"\n";
			
			if(cache_option.Value == "No Cache")
				view_commands += "NoCache \n";
			
		}		
		
		var parallel_clause as EA.TaggedValue;
		parallel_clause = view_Element.TaggedValues.GetByName("Parallel Clause");
		
		if(parallel_clause != null)
		{
			if(parallel_clause.Value == "Parallel")
				view_commands += "Parallel \n ";
			else if(parallel_clause.Value == "No Parallel")
				view_commands += "NoParallel \n ";
			
			var parallel_range as EA.TaggedValue;
			parallel_range = view_Element.TaggedValues.GetByName("Parallel Range");
		
			if(parallel_range != null && parallel_range.Value !="")
				view_commands += parallel_range.Value+"\n";		
			
		}
		
		var build_option as EA.TaggedValue;
		build_option = view_Element.TaggedValues.GetByName("Build Option");
		
		if(build_option != null && build_option.Value != "" && build_option.Value != "<none>")
			view_commands += "Build "+build_option.Value+"\n";	

		var index_option as EA.TaggedValue;
		index_option = view_Element.TaggedValues.GetByName("Index Option");
		
		if(index_option != null)
		{
			if(index_option.Value == "Yes")
				view_commands += "Using Index \n";	
			else if(index_option.Value == "No")
				view_commands += "Using No Index \n";	
			
			var index_clause as EA.TaggedValue;
			index_clause = view_Element.TaggedValues.GetByName("Index Clause");
			
			if(index_clause != null && index_clause.Notes != "")
				view_commands += index_clause.Notes+ "\n";			
		}
		
		var refresh_clause as EA.TaggedValue;
		refresh_clause = view_Element.TaggedValues.GetByName("Refresh Clause");
		
		if(refresh_clause != null && refresh_clause.Notes != "")
			view_commands += refresh_clause.Notes+ "\n";		
		
		var evaluation as EA.TaggedValue;
		evaluation = view_Element.TaggedValues.GetByName("Evaluation Edition");
		
		if(evaluation != null && evaluation.Value != "")
			view_commands += "Evaluate Using "+evaluation.Value+ "\n";		
		
		var query_computation as EA.TaggedValue;
		query_computation = view_Element.TaggedValues.GetByName("Query Computation");
		
		if(query_computation != null && query_computation.Value != "" && query_computation.Value != "<none>")
			view_commands += query_computation.Value+" On Query Computation \n";
		
		
		var query_rewrite as EA.TaggedValue;
		query_rewrite = view_Element.TaggedValues.GetByName("Query Rewrite");
		
		if(query_rewrite != null && query_rewrite.Value != "" && query_rewrite.Value != "<none>")
			view_commands += query_rewrite.Value+" Query Rewrite \n";
		
		var unusable_ed as EA.TaggedValue;
		unusable_ed = view_Element.TaggedValues.GetByName("Unusable Edition");
		
		if(unusable_ed != null && unusable_ed.Value != "" )
			view_commands += unusable_ed.Value+" \n";
		
		var sharing_clause as EA.TaggedValue;
		sharing_clause = view_Element.TaggedValues.GetByName("Sharing Clause");
		
		if(sharing_clause != null && sharing_clause.Value !="")
			view_commands += "Sharing = "+sharing_clause.Value+"\n";
		
		var mat_view_option as EA.TaggedValue;
		mat_view_option = view_Element.TaggedValues.GetByName("Materialized View Option");
		
		if(mat_view_option != null && mat_view_option.Notes != "")
			view_commands += "With "+mat_view_option.Notes+"\n";
		
		var log_purge as EA.TaggedValue;
		log_purge = view_Element.TaggedValues.GetByName("Log Purge");
		
		if(log_purge != null && log_purge.Notes != "")
			view_commands += "Purge "+log_purge.Notes+"\n";
		
		var refresh_for as EA.TaggedValue;
		refresh_for = view_Element.TaggedValues.GetByName("Refresh For");
		
		if(refresh_for != null)
		{
			if(refresh_for.Value == "Synchronous" )
				view_commands += "For Synchronous Refresh \n";
			else if(refresh_for.Value == "Fast")
				view_commands += "For Fast Refresh \n";
			
			var staging_log as EA.TaggedValue;
			staging_log = view_Element.TaggedValues.GetByName("Staging Log Name");
			
			if(staging_log != null && staging_log.Value != "")
				view_commands += "Using "+staging_log.Value+"\n";			
		}
		
		var caption as EA.TaggedValue;
		caption = view_Element.TaggedValues.GetByName("Caption");
		
		if(caption != null && caption.Value != "")
			view_commands += "Caption "+caption.Value+"\n";	
		
		var description as EA.TaggedValue;
		description = view_Element.TaggedValues.GetByName("Description");
		
		if(description != null && description.Value != "")
			view_commands += "Description "+description.Value+"\n";	
		
		var classification as EA.TaggedValue;
		classification = view_Element.TaggedValues.GetByName("Classification Name");
		
		if(classification != null && classification.Value != "")
			view_commands += "Classification "+classification.Value+"\n";	
		
		var classification_value as EA.TaggedValue;
		classification_value = view_Element.TaggedValues.GetByName("Classification Value");
		
		if(classification_value != null && classification_value.Value != "")
			view_commands += "Value "+classification_value.Value+"\n";	
		
		var language as EA.TaggedValue;
		language = view_Element.TaggedValues.GetByName("Language");
		
		if(language != null && language.Value != "")
			view_commands += "Language "+language.Value+"\n";	
		
		var view_parms as EA.TaggedValue;
		view_parms = view_Element.TaggedValues.GetByName("View Parameters");
		
		if(view_parms != null && view_parms.Notes != "")
			view_commands += "( "+view_parms.Notes+" )\n";	
		
		var object_view as EA.TaggedValue;
		object_view = view_Element.TaggedValues.GetByName("Object View");
		
		if(object_view != null && object_view.Notes != "")
			view_commands += object_view.Notes+"\n";	
		
		var xml_view_clause as EA.TaggedValue;
		xml_view_clause = view_Element.TaggedValues.GetByName("XMLType View Clause");
		
		if(xml_view_clause != null && xml_view_clause.Notes != "")
			view_commands += xml_view_clause.Notes+"\n";	
		
		var source_clause as EA.TaggedValue;
		source_clause = view_Element.TaggedValues.GetByName("Source Clause");
		
		if(source_clause !=  null && source_clause.Value != "")
			view_commands += "Using "+source_clause.Value+"\n";	
		
		var dim_key as EA.TaggedValue;
		dim_key = view_Element.TaggedValues.GetByName("Dimension Key");
		
		if(dim_key != null && dim_key.Notes != "")
			view_commands += "Dimension By ( "+dim_key.Notes+" )\n";	
		
		var measure_clause as EA.TaggedValue;
		measure_clause = view_Element.TaggedValues.GetByName("Measure By");
		
		if(measure_clause != null && measure_clause.Notes != "")
			view_commands += "Measures ( "+measure_clause.Notes+" )\n";	
		
		var default_measure as EA.TaggedValue;		
		default_measure = view_Element.TaggedValues.GetByName("Default Measure");
		
		if(default_measure != null && default_measure.Value != "")
			view_commands += "Default Measure "+ default_measure.Value + "\n"; 
		
		var aggr_by as EA.TaggedValue;
		aggr_by = view_Element.TaggedValues.GetByName("Aggregate By");
		
		if(aggr_by != null &&  aggr_by.Value != "")
			view_commands += "Default Aggregate By "+ aggr_by.Value + "\n"; 
		
		var cache_option as EA.TaggedValue;
		cache_option = view_Element.TaggedValues.GetByName("Cache Specification");
		
		if(cache_option != null && cache_option.Notes != "")
			view_commands += "Cache "+ cache_option.Notes + "\n"; 
		
		var fact_columns as EA.TaggedValue;
		fact_columns = view_Element.TaggedValues.GetByName("Fact Columns");
		
		if(fact_columns != null && fact_columns.Notes != "")
			view_commands += "Fact Columns "+ fact_columns.Notes + "\n"; 
		
		var query_transform as EA.TaggedValue;
		query_transform = view_Element.TaggedValues.GetByName("Query Transform");
		
		if(query_transform != null && query_transform.Value == "True")
			view_commands += "Enable Query Transform \n"; 
		
		var rely_option as EA.TaggedValue;
		rely_option = view_Element.TaggedValues.GetByName("Rely Option");
		
		if(rely_option != null)
		{
			if(rely_option.Value == "Yes")
				view_commands += "Rely \n"; 
			else if(rely_option.Value == "No")
				view_commands += "NoRely \n"; 			
		}
		
		var bequeath as EA.TaggedValue;
		bequeath = view_Element.TaggedValues.GetByName("Bequeath");
		
		if(bequeath != null)
		{
			if(bequeath.Value == "Current User")
				view_commands += "Bequeath Current User \n";
			else if(bequeath.Value == "Definer")
				view_commands += "Bequeath Definer \n";
		}
		
		var view_def as EA.TaggedValue;
		view_def = view_Element.TaggedValues.GetByName("viewdef");
		
		if(view_def != null && view_def.Notes != "")
			view_commands += "As "+view_def.Notes+"\n";
		
		var container_option as EA.TaggedValue;
		container_option = view_Element.TaggedValues.GetByName("Container Option");
		
		if(container_option != null)
		{
			if(container_option.Value == "Map")
				view_commands += "Container_Map \n";
			else if(container_option.Value == "Default")
				view_commands += "Container_Default \n";			
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return view_commands;
}
function create_seq_command(table_element)
{
	var seq_commands = "Create Sequence ";
	try
	{
		var db_schema as EA.TaggedValue;
		db_schema = table_element.TaggedValues.GetByName("Database and Schema");
		
		if(db_schema != null && db_schema.Value != "")
		{
			if(db_schema.Value.endsWith("."))
			seq_commands += "\""+db_schema.Value+"\"";
			else
				seq_commands += "\""+db_schema.Value+"\".";
			
		}
		
		seq_commands += "\""+table_element.Name+"\"\n";
		
		var sharing_clause as EA.TaggedValue;
		sharing_clause = table_element.TaggedValues.GetByName("Sharing Clause");
		
		if(sharing_clause != null && sharing_clause.Value !="")
			seq_commands += "Sharing = "+sharing_clause.Value+"\n";		
		
		var increment_by as EA.TaggedValue;
		increment_by = table_element.TaggedValues.GetByName("Increment By");
		
		if(increment_by != null && increment_by.Value !="")
			seq_commands += "Increment By "+increment_by.Value+"\n";		
		
		var start_with as EA.TaggedValue;
		start_with = table_element.TaggedValues.GetByName("Start With");
		
		if(start_with != null && start_with.Value !="")
			seq_commands += "Start With "+start_with.Value+"\n";
		
		var max_value as EA.TaggedValue;
		max_value = table_element.TaggedValues.GetByName("Maximum Value");
		
		if(max_value != null)
		{	
			if(max_value.Value == "Yes")
			{
				seq_commands += "MaxValue ";
				
				var max_num as EA.TaggedValue;
				max_num = table_element.TaggedValues.GetByName("Maximum Number");
			
				if(max_num != null && max_num.Value !="")
					seq_commands += max_num.Value+"\n";
			}
			
			if(max_value.Value == "No")
				seq_commands += "NoMaxValue \n";
		}
		
		var min_value as EA.TaggedValue;
		min_value = table_element.TaggedValues.GetByName("Minimum Value");
		
		if(min_value != null)
		{	
			if(min_value.Value == "Yes" )
			{
				seq_commands += "MinValue ";
			
				var min_num as EA.TaggedValue;
				min_num = table_element.TaggedValues.GetByName("Minimum Number");
			
				if(min_num != null )
					seq_commands += min_num.Value+"\n";
			}
			
			if(min_value.Value == "No" )
				seq_commands += "NoMinValue \n";
		}
		
		var cycle as EA.TaggedValue;
		cycle = table_element.TaggedValues.GetByName("Cycle");
		
		if(cycle != null )
		{
			if(cycle.Value == "Yes")
				seq_commands += "Cycle \n";
			else if(cycle.Value == "No")
				seq_commands += "NoCycle \n";
		}	
		
		var cache_option as EA.TaggedValue;
		cache_option = table_element.TaggedValues.GetByName("Caching Option");
		
		if(cache_option != null)
		{	
			if(cache_option.Value == "Cache")
			{
				seq_commands += "Cache ";
			
				var cache_value as EA.TaggedValue;
				cache_value = table_element.TaggedValues.GetByName("Cache Value");
			
				if(cache_value != null && cache_value.Value !="")
					seq_commands += cache_value.Value+"\n";
			}
			if(cache_option.Value == "No Cache")
				seq_commands += "NoCache \n";
		}
		
		var order as EA.TaggedValue;
		order = table_element.TaggedValues.GetByName("Order");
		
		if(order != null )
		{
			if(order.Value == "Yes")
				seq_commands += "Order \n";
			else if(order.Value == "No")
				seq_commands += "NoOrder \n";
		}	
		
		var keep_option as EA.TaggedValue;
		keep_option = table_element.TaggedValues.GetByName("Keep Option");
		
		if(keep_option != null )
		{
			if(keep_option.Value == "Yes")
				seq_commands += "Keep \n";
			else if(keep_option.Value == "No")
				seq_commands += "NoKeep \n";
		} 		
		
		var scale_option as EA.TaggedValue;
		scale_option = table_element.TaggedValues.GetByName("Scale Option");
		
		if(scale_option != null)
		{	
			if(scale_option.Value == "Yes")
			{
				seq_commands += "Scale ";
			
				var scale_value as EA.TaggedValue;
				scale_value = table_element.TaggedValues.GetByName("Scale Option");
			
				if(scale_value != null && scale_value.Value !="" && scale_value.Value !="<none>" )
					seq_commands += scale_value.Value+"\n";
			}
			
			if(scale_option.Value == "No")
				seq_commands += "NoScale \n";
		}	
		
		var scope_specification as EA.TaggedValue;
		scope_specification = table_element.TaggedValues.GetByName("Scope Specification");

		if(scope_specification != null && scope_specification.Value !="" && scope_specification.Value !="<none>")
			seq_commands += scope_specification.Value+"\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
	return seq_commands;
}

function create_func_commands(func_element)
{
	var func_command = "Create ";
	try
	{		
		var is_replace as EA.TaggedValue;
		is_replace = func_element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			func_command += "Or Replace ";
		
		var func_type as EA.TaggedValue;
		func_type = func_element.TaggedValues.GetByName("Function Type");
		
		if(func_type != null )
		{
			if(func_type.Value == "Editionable")
				func_command += "Editionable ";
			else if(func_type.Value == "Non Editionable")
				func_command += "NonEditionable ";
		}	

		func_command += "Function ";
		
		var db_schema as EA.TaggedValue;
		db_schema = func_element.TaggedValues.GetByName("Database and Schema");
		
		if(db_schema != null && db_schema.Value != "")
		{
			if(db_schema.Value.endsWith("."))
			func_command += "\""+db_schema.Value+"\"";
			else
				func_command += "\""+db_schema.Value+"\".";
			
		}
		
		func_command += "\""+func_element.Name+"\"\n";
		
		var parm_decl as EA.TaggedValue;
		parm_decl = func_element.TaggedValues.GetByName("Parameter Declaration");
		
		if(parm_decl != null && parm_decl.Notes != "")
			func_command += "( " +parm_decl.Notes + " )\n";
		
		var return_type as EA.TaggedValue;
		return_type = func_element.TaggedValues.GetByName("Return Type");
		
		if(return_type != null && return_type.Value != "")
			func_command += "Return "+return_type.Value+"\n";
		
		var sharing_clause as EA.TaggedValue;
		sharing_clause = func_element.TaggedValues.GetByName("Sharing Clause");
		
		if(sharing_clause != null && sharing_clause.Value !="")
			func_command += "Sharing = "+sharing_clause.Value+"\n";				
		
		var invoke_rights as EA.TaggedValue;
		invoke_rights = func_element.TaggedValues.GetByName("Invoker Rights");
		
		if(invoke_rights != null)
		{
			if(invoke_rights.Value == "Current User")
				func_command += "AuthId Current_User\n";	
			else if(invoke_rights.Value == "Definer")
				func_command += "AuthId Definer\n";							
		}
		
		var accessible_by as EA.TaggedValue;
		accessible_by = func_element.TaggedValues.GetByName("Accesible By");
		
		if(accessible_by != null && accessible_by.Notes !="")
			func_command += "Accessible By "+accessible_by.Notes+"\n";	

		var default_collation as EA.TaggedValue;
		default_collation = func_element.TaggedValues.GetByName("Default Collation");
		
		if(default_collation != null && default_collation.Value == "True")
			func_command += "Default Collation USING_NLS_COMP \n";
		
		var deterministic as EA.TaggedValue;
		deterministic = func_element.TaggedValues.GetByName("Deterministic");
		
		if(deterministic != null && deterministic.Value == "True")
			func_command += "Deterministic \n";
		
		var paraller_enable as EA.TaggedValue;
		paraller_enable = func_element.TaggedValues.GetByName("Parallel Enable");
		
		if(paraller_enable != null && paraller_enable.Value == "True")
			func_command += "Parallel_Enable \n";
		
		var partition_by as EA.TaggedValue;
		partition_by = func_element.TaggedValues.GetByName("Partition By");
		
		if(partition_by != null && partition_by.Notes != "")
			func_command += "( " +partition_by.Notes+ " )\n";
		
		var result_cache as EA.TaggedValue;
		result_cache = func_element.TaggedValues.GetByName("Result Cache");
		
		if(result_cache != null && result_cache.Notes !="")
			func_command += "Result_Cache "+result_cache.Notes+"\n";	
		
		var aggr_clause as EA.TaggedValue;
		aggr_clause = func_element.TaggedValues.GetByName("Aggregate By");
		
		if(aggr_clause != null && aggr_clause.Value != "")
			func_command += "Aggregate Using "+aggr_clause.Value+"\n";	
		
		var pipeline as EA.TaggedValue;
		pipeline = func_element.TaggedValues.GetByName("Pipeline");
		
		if(pipeline != null && pipeline.Notes !="")
			func_command += "Pipeline "+pipeline.Notes+"\n";	
		
		
		var sql_macro as EA.TaggedValue;
		sql_macro = func_element.TaggedValues.GetByName("Sql Macro");
		
		if(sql_macro != null)
		{
			if(sql_macro.Value == "Scalar")
				func_command += "Sql_Macro ( Type = > ( Scalar ) )\n";	
			else if(sql_macro.Value == "Table")
				func_command += "Sql_Macro ( Type = > ( Table ) )\n";				
		}
		
		var obj_indicator as EA.TaggedValue;
		obj_indicator = func_element.TaggedValues.GetByName("Object Body Indicator");
		
		if(obj_indicator != null && obj_indicator.Value != "" && obj_indicator.Value != "<none>")
			func_command += obj_indicator.Value+"\n";		

		var func_def as EA.TaggedValue;
		func_def = func_element.TaggedValues.GetByName("funcdef");
		
		if(func_def != null && func_def.Notes != "")
			func_command += func_def.Notes+"\n";
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	return func_command;
		
}

function create_procedure_command(proc_element)
{
	var proc_commands = "Create ";
	try
	{
		var is_replace as EA.TaggedValue;
		is_replace = proc_element.TaggedValues.GetByName("Is Replace");
		
		if(is_replace != null && is_replace.Value == "True")
			proc_commands += "Or Replace ";
		
		var proc_type as EA.TaggedValue;
		proc_type = proc_element.TaggedValues.GetByName("Procedure Type");
		
		if(proc_type != null )
		{
			if(proc_type.Value == "Editionable")
				proc_commands += "Editionable ";
			else if(proc_type.Value == "Non Editionable")
				proc_commands += "NonEditionable ";
		}	

		proc_commands += "Procedure ";
		
		var db_schema as EA.TaggedValue;
		db_schema = proc_element.TaggedValues.GetByName("Database and Schema");
		
		if(db_schema != null && db_schema.Value != "")
		{
			if(db_schema.Value.endsWith("."))
			proc_commands += "\""+db_schema.Value+"\"";
			else
				proc_commands +="\""+ db_schema.Value+"\".";
			
		}
		
		proc_commands += "\""+proc_element.Name+"\"\n";
		
		var parm_decl as EA.TaggedValue;
		parm_decl = proc_element.TaggedValues.GetByName("Parameter Declaration");
		
		if(parm_decl != null && parm_decl.Notes != "")
			proc_commands += "( " +parm_decl.Notes + " )\n";
		
		var return_type as EA.TaggedValue;
		return_type = proc_element.TaggedValues.GetByName("Return Type");
		
		if(return_type != null && return_type.Value != "")
			proc_commands += "Return "+return_type.Value+"\n";
		
		var sharing_clause as EA.TaggedValue;
		sharing_clause = proc_element.TaggedValues.GetByName("Sharing Clause");
		
		if(sharing_clause != null && sharing_clause.Value !="")
			proc_commands += "Sharing = "+sharing_clause.Value+"\n";				
		
		var default_collation as EA.TaggedValue;
		default_collation = proc_element.TaggedValues.GetByName("Default Collation");
		
		if(default_collation != null && default_collation.Value == "True")
			proc_commands += "Default Collation USING_NLS_COMP \n";
		
		var invoke_rights as EA.TaggedValue;
		invoke_rights = proc_element.TaggedValues.GetByName("Invoker Rights");
		
		if(invoke_rights != null)
		{
			if(invoke_rights.Value == "Current User")
				proc_commands += "AuthId Current_User\n";	
			else if(invoke_rights.Value == "Definer")
				proc_commands += "AuthId Definer\n";							
		}
		
		var accessible_by as EA.TaggedValue;
		accessible_by = proc_element.TaggedValues.GetByName("Accesible By");
		
		if(accessible_by != null && accessible_by.Notes !="")
			proc_commands += "Accessible By "+accessible_by.Notes+"\n";	
		
		var obj_indicator as EA.TaggedValue;
		obj_indicator = proc_element.TaggedValues.GetByName("Object Body Indicator");
		
		if(obj_indicator != null && obj_indicator.Value != "" && obj_indicator.Value != "<none>")
			proc_commands += obj_indicator.Value+"\n";		

		var proc_def as EA.TaggedValue;
		proc_def = proc_element.TaggedValues.GetByName("procdef");
		
		if(proc_def != null && proc_def.Notes != "")
			proc_commands += proc_def.Notes+"\n";	
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return proc_commands;
}

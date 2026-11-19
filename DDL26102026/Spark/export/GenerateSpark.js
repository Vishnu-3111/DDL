!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for Apache spark Database only
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
		var genOutputType = ssproperties.get('GenerateOutput');
		var file;
		var filepath ;
		var fileSystemObj = new COMObject("Scripting.FileSystemObject");
		if(genOutputType=="0")
		{
			filepath =  ssproperties.get('Filename');
			file = fileSystemObj.OpenTextFile(filepath, 2, true);
		}
		else
		{
			filepath =  ssproperties.get('FilePath');
		}
		var ddl_Element as EA.Element
		
		var i = 0;
		var guid = ssproperties.get('Object' + i); // To get elements guid from the Generate ddl window
		
		while (guid != undefined)
		{	
			ddl_Element = Repository.GetElementByGuid(guid); // Selected elements from Generate ddl file window
			if(genOutputType == "1")
				
			file=fileSystemObj.OpenTextFile(filepath + ddl_Element.Name + ".sql", 2, true);
			CreateDDLCommands(ddl_Element,file);	
			if(genOutputType == "1")
			file.Close();
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

function CreateDDLCommands(ddl_Element,file)
{
	var query = "";

	if(ddl_Element.FQStereotype == "Spark::table") // To convert Table Elements into Create table commands
		query = getTableElements(ddl_Element); 	
	else if(ddl_Element.FQStereotype == "Spark::view")// To convert view Elements into Create View commands
		query = getViewElements(ddl_Element);
	else if(ddl_Element.FQStereotype == "Spark::function")//To convert function Elements into Create function commands
		query = getFunctionElements(ddl_Element);

	if(query != "")		
	{
		query+=";\n";
		file.WriteLine(query);
	}
}

function getTableElements(ddl_Element)
{
	var query ="";
	
	try
	{
		query = "CREATE ";

		var isexternal as EA.TaggedValue;
		isexternal = ddl_Element.TaggedValues.GetByName("Is External");

		if(isexternal!=null && isexternal.Value=="True" )
			query += "EXTERNAL ";			

		query += "TABLE ";			

		var Not_Exist as EA.TaggedValue;
		 Not_Exist = ddl_Element.TaggedValues.GetByName("Not Exist")

		if(Not_Exist!=null && Not_Exist.Value=="True")
			query += "IF NOT EXISTS ";	

			var schema_and_db as EA.TaggedValue;
		 schema_and_db = ddl_Element.TaggedValues.GetByName("Schema and Database")
		
			if(schema_and_db!=null &&schema_and_db.Value!="")
			{
				if(schema_and_db.Value.endsWith("."))
					query += schema_and_db.Value ;
				else
					query += "`"+schema_and_db.Value+"`." ;
			}
		
		query += "`"+ddl_Element.Name+"` \n";

		//Column details 
		
		var column as EA.Attribute;

		if(ddl_Element.Attributes.Count>0)
			query += getTableColumns(ddl_Element,column) ; //method for get table columns and its properties	
		
		query += getTableLike(ddl_Element);	//Like Table query details	
		
		query += getTableProperties(ddl_Element);	//Additional Table properties		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	
	return query;
}

function getTableColumns(ddl_Element,column)
{
	var query = "";
	
	try
	{
		query += "(\n";			

		for(var j=0; j< ddl_Element.Attributes.Count; j++)
		{				
			column = ddl_Element.Attributes.GetAt(j);

			query += "`"+column.Name+"` "+column.Type;

			if(column.Precision!=0)
			{
				query +="("+column.Precision;

				if(column.Scale!=0 )
				query += ","+column.Scale;

				query += ")";						 
			}
			
			var filel_type as EA.TaggedValue;
			filel_type = column.TaggedValues.GetByName("Field Value Types");

			if(filel_type != null && filel_type.Notes != "")
				query += filel_type.Notes

			var columncomment as EA.TaggedValue;
			columncomment = column.TaggedValues.GetByName("Comment");

			if(columncomment != null && columncomment.Value != "")
				query += "COMMENT "+"'"+columncomment.Value+"'";

			if(j != ddl_Element.Attributes.Count-1)
				query += ", \n";
		}
			
		query += "\n)\n";		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	
	return query;
}

function getTableLike(ddl_Element)
{
	var query = "";
	try
	{
		var ele_connector as EA.Connector;

		for(var s=0; s<ddl_Element.Connectors.Count; s++)
		{
			ele_connector = ddl_Element.Connectors.GetAt(s);

			var source_id = ele_connector.ClientID;

			if(source_id == ddl_Element.ElementID && ele_connector.FQStereotype == "Spark::like")
			{
				//To Get source table name
				var targetElement = Repository.GetElementByID(ele_connector.SupplierID)
				query += "Like ";
				
				var target_table_schema as EA.TaggedValue;
				target_table_schema = ele_connector.TaggedValues.GetByName("Target Table schema")
				
				if(target_table_schema!=null &&target_table_schema.Value!="")
				{
					if(target_table_schema.Value.endsWith("."))
						query += target_table_schema.Value ;
					else
						query += "`"+target_table_schema.Value+"`." ;
				}
				query += "`"+targetElement.Name+"`\n";	
			}				
		}		
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return query;	
}

function getTableProperties(ddl_Element)
{
	var query = "";
	
	try
	{
		var data_source as EA.TaggedValue;
		data_source = ddl_Element.TaggedValues.GetByName("Data Source");

		if(data_source != null && data_source.Value != "")
			query += "Using "+data_source.Value+"\n";

		var table_properties as EA.TaggedValue;
		table_properties = ddl_Element.TaggedValues.GetByName("Table Properties");

		if(table_properties != null && table_properties.Notes != "")
			query += "TBLPROPERTIES ("+table_properties.Notes+")\n";

		var table_Option as EA.TaggedValue;
		table_Option = ddl_Element.TaggedValues.GetByName("Table Options");

		if(table_Option != null && table_Option.Notes != "")
			query += "OPTIONS (\n"+table_Option.Notes+"\n)\n";

		var table_commets as EA.TaggedValue;
		table_commets = ddl_Element.TaggedValues.GetByName("Comment");

		if(table_commets != null && table_commets.Value != "")
			query += "COMMENT "+table_commets.Value+"\n";

		var Partitioned_by as EA.TaggedValue;
		Partitioned_by = ddl_Element.TaggedValues.GetByName("Partition By");

		if(Partitioned_by != null && Partitioned_by.Notes != "")
			query += "PARTITIONED BY "+"("+Partitioned_by.Notes+") \n";

		var clustered_by as EA.TaggedValue;
		clustered_by = ddl_Element.TaggedValues.GetByName("Clustered By");

		if(clustered_by != null && clustered_by.Notes != "")
		{
			query += "CLUSTERED BY "+"("+clustered_by.Notes+")\n";

			var Sorted_by as EA.TaggedValue;
			Sorted_by = ddl_Element.TaggedValues.GetByName("Sorted By");

			if(Sorted_by != null && Sorted_by.Notes != "")
				query += "SORTED BY "+"("+Sorted_by.Notes+") \n";

			var num_Buckets as EA.TaggedValue;
			num_Buckets = ddl_Element.TaggedValues.GetByName("Number of Buckets");

			if(num_Buckets != null && num_Buckets.Value != "")
				query += "INTO "+ num_Buckets.Value+" BUCKETS \n";
		}

		var row_format as EA.TaggedValue;
		row_format = ddl_Element.TaggedValues.GetByName("Row Format");

		if(row_format != null && row_format.Notes != "")
			query += "ROW FORMAT "+ row_format.Notes+"\n";

		var fileformat as EA.TaggedValue;
		fileformat = ddl_Element.TaggedValues.GetByName("Stored As");

		if(fileformat != null && fileformat.Value != "" && fileformat.Value!="Format Options")
		{
			query += "STORED AS "+ fileformat.Value+"\n";
		}
		else if(fileformat.Value=="Format Options")
		{
			var input_format as EA.TaggedValue;
			input_format = ddl_Element.TaggedValues.GetByName("Input Format");
			
			if(input_format.Value!=null && input_format.Value!="")
				query += "STORED AS "+ "INPUTFORMAT "+ input_format.Value+"\n";
			
			var output_format as EA.TaggedValue;
			output_format = ddl_Element.TaggedValues.GetByName("Input Format");
			
			if(output_format.Value!=null && output_format.Value!="")
				query += "OUTPUTFORMAT "+ output_format.Value+"\n";
			
		}

		var taglocation as EA.TaggedValue;
		taglocation = ddl_Element.TaggedValues.GetByName("Location");

		if(taglocation != null && taglocation.Value != "")
			query += "LOCATION "+ taglocation.Value+"\n";

		var select_query as EA.TaggedValue;
		select_query = ddl_Element.TaggedValues.GetByName("Select Query");

		if(select_query != null && select_query.Notes != "")
			query += "AS "+ select_query.Notes+"\n";		
		
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return query;
}

function getViewElements(ddl_Element)
{
	var query = "";
	
	try
	{
		query = "CREATE ";

		var isReplace as EA.TaggedValue;
		isReplace = ddl_Element.TaggedValues.GetByName("Is Replace");

		if(isReplace != null && isReplace.Value=="True")
			query += "OR REPLACE ";

		var isGobal as EA.TaggedValue;
		isGobal = ddl_Element.TaggedValues.GetByName("Is Global");

		if(isGobal != null && isGobal.Value=="True")
			query += "GLOBAL ";

		var isTemporary as EA.TaggedValue;
		isTemporary = ddl_Element.TaggedValues.GetByName("Is Temporary");

		if(isTemporary != null && isTemporary.Value=="True")
			query += "TEMPORARY ";

		query += "VIEW ";

		var notExist as EA.TaggedValue;
		notExist = ddl_Element.TaggedValues.GetByName("Not Exist");

		if(notExist != null && notExist.Value=="True")
			query += "IF NOT EXISTS ";
		
		var schema_and_db as EA.TaggedValue;
		 schema_and_db = ddl_Element.TaggedValues.GetByName("Schema and Database")
		
		
		if(schema_and_db!=null &&schema_and_db.Value!="")
			{
				if(schema_and_db.Value.endsWith("."))
					query += schema_and_db.Value ;
				else
					query += "`"+schema_and_db.Value+"`." ;
			}

		query +=ddl_Element.Name+"\n";


		var columnsdetails as EA.TaggedValue;
		columnsdetails = ddl_Element.TaggedValues.GetByName("View Columns");

		if(columnsdetails != null && columnsdetails.Notes != "")
			query += "("+columnsdetails.Notes+")\n";			

		var viewComment as EA.TaggedValue;
		viewComment = ddl_Element.TaggedValues.GetByName("Comment");

		if(viewComment != null && viewComment.Value!="")
			query +="COMMENT " +viewComment.Value+"\n";

		var tableProperties as EA.TaggedValue;
		tableProperties = ddl_Element.TaggedValues.GetByName("Table Properties");

		if(tableProperties != null && tableProperties.Notes !="")
			query += "TBLPROPERTIES ("+tableProperties.Notes+")\n";			

		var viewDefinition as EA.TaggedValue;
		viewDefinition = ddl_Element.TaggedValues.GetByName("viewdef");

		if(viewDefinition != null && viewDefinition.Notes != "")
			query += "AS "+ viewDefinition.Notes+"\n";		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return query;	
}

function getFunctionElements(ddl_Element)
{
	var query = "";
	
	try
	{
		query = "CREATE ";

		var isReplace as EA.TaggedValue;
		isReplace = ddl_Element.TaggedValues.GetByName("Is Replace");

		if(isReplace != null && isReplace.Value=="True")
			query += "OR REPLACE ";

		var isTemporary as EA.TaggedValue;
		isTemporary = ddl_Element.TaggedValues.GetByName("Is Temporary");

		if(isTemporary != null && isTemporary.Value=="True")
			query += "TEMPORARY ";			

		query+="FUNCTION ";

		var notExist as EA.TaggedValue;
		notExist = ddl_Element.TaggedValues.GetByName("Not Exist");

		if(notExist != null && notExist.Value=="True")
			query += "IF NOT EXISTS ";
		
		var schema_and_db as EA.TaggedValue;
		 schema_and_db = ddl_Element.TaggedValues.GetByName("Schema and Database")
		
		
		if(schema_and_db!=null &&schema_and_db.Value!="")
			{
				if(schema_and_db.Value.endsWith("."))
					query += schema_and_db.Value ;
				else
					query += "`"+schema_and_db.Value+"`." ;
			}

		query += ddl_Element.Name+"\n";

		var className as EA.TaggedValue;
		className = ddl_Element.TaggedValues.GetByName("Class Name");

		if(className != null && className.Value != "")
			query += "AS"+className.Value +"\n";			

		var resourceLocation as EA.TaggedValue;
		resourceLocation = ddl_Element.TaggedValues.GetByName("Resource Location");

		if(resourceLocation != null && resourceLocation.Notes != "")
			query += "USING "+resourceLocation.Notes+"\n" ;
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return query;
	
}



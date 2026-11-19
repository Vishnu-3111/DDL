!INC Local Scripts.EAConstants-JavaScript
/*
	This script is applied for MongoDB database only
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
			createDDldocument(ddl_Element,file);
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
	
function createDDldocument(Mongo_Element,file)
{
	try
	{
		var create_document="";
		
		if( Mongo_Element.FQStereotype=="MongoDB::collection")
		{
			if(Mongo_Element.Attributes.Count==0)
				create_document+=createCollection(Mongo_Element);			
			else if(Mongo_Element.Attributes.Count!=0)
				create_document+=insertmethod(Mongo_Element);		
			
			
			if(Mongo_Element.Methods.Count!=0)
			{
				for (var k=0;k<Mongo_Element.Methods.Count;k++)
				{
					var operation as EA.Method
					operation=Mongo_Element.Methods.GetAt(k);
					
					if(operation.FQStereotype=="MongoDB::index")
					{
						create_document+=createindex(Mongo_Element,operation);
					}
				}
				
			}
		}
		else if( Mongo_Element.FQStereotype=="MongoDB::view")
		{
			create_document+="db.createView(\""+Mongo_Element.Name+"\"";
			var sourcecollection as EA.TaggedValue
			sourcecollection=Mongo_Element.TaggedValues.GetByName("SourceName");
			
			if(sourcecollection!=null&&sourcecollection.Value!="")
				create_document+=",\""+sourcecollection.Value+"\"";
			
			var viewdefinition as EA.TaggedValue
			viewdefinition=Mongo_Element.TaggedValues.GetByName("viewdef");
			if(viewdefinition!=null&&viewdefinition.Notes!="")
				create_document+=",\n"+viewdefinition.Notes+"";
			
			var collation as EA.TaggedValue
			collation=Mongo_Element.TaggedValues.GetByName("Collation");
			if(collation!=null&&collation.Notes!="")
			create_document+=",\n{ collation :"+collation.Notes+"}";
			create_document+="\n);\n\n"
		}
		else if(Mongo_Element.FQStereotype=="MongoDB::procedure")
		{
			create_document+="db.system.js.insertOne({ \n _id: \""+Mongo_Element.Name+"\"";
			var functionbody as EA.TaggedValue
			functionbody=Mongo_Element.TaggedValues.GetByName("procdef");
			
			if(functionbody!=null&&functionbody.Value!="")
				create_document+=",\n value :"+functionbody.Notes;
			
			create_document+="}\n);\n\n";
		}	
		else if(Mongo_Element.FQStereotype=="MongoDB::function")
		{
			create_document+="function "+Mongo_Element.Name+"(";
			
			var function_parameter as EA.TaggedValue
			function_parameter=Mongo_Element.TaggedValues.GetByName("Function Parameter");
			
			if(function_parameter!=null&&function_parameter.Value!="")
			{
				create_document+= function_parameter.Value
			}
			create_document+= ") \n{\n "			
			
			var funcdrf as EA.TaggedValue
			funcdef=Mongo_Element.TaggedValues.GetByName("funcdef");
			
			if(funcdef!=null&&funcdef.Value!="")
				create_document+=funcdef.Value;
			
		create_document+="};\n\n";
		}	

		if(create_document != "")		
			file.WriteLine(create_document);
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}		
}

function createCollection( Mongo_Element)
{
	var create_document = "";
	
	try
	{
		create_document= "db.createCollection(\""+Mongo_Element.Name+"\"";
		var cappedcollection as EA.TaggedValue
		cappedcollection = Mongo_Element.TaggedValues.GetByName("capped");	
		
		var collectionOptions=[];
		var collectionOptionSyntax="";		
		
		if(cappedcollection != null && cappedcollection.Value == "True")
		{
			collectionOptionSyntax= "capped: true";
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var changestream as EA.TaggedValue
		changestream=Mongo_Element.TaggedValues.GetByName("changeStreamPreAndPostImages");
		if(changestream!=null&&changestream.Notes!="")
		{
			collectionOptionSyntax= "changeStreamPreAndPostImages :"+changestream.Notes;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var collation as EA.TaggedValue
		collation=Mongo_Element.TaggedValues.GetByName("Collation");
		if(collation!=null && collation.Notes!="")
		{
			collectionOptionSyntax="collation:"+collation.Notes;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var size as EA.TaggedValue
		size=Mongo_Element.TaggedValues.GetByName("size");
		if(size!=null&&size.Value!="")
		{
			collectionOptionSyntax="size :"+size.Value;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var max as EA.TaggedValue
		max=Mongo_Element.TaggedValues.GetByName("max");
		if(max!=null&&max.Value!="")
		{
			collectionOptionSyntax="max :"+max.Value;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var storageEngine as EA.TaggedValue
		storageEngine=Mongo_Element.TaggedValues.GetByName("storageEngine");
		if(storageEngine!=null&&storageEngine.Notes!="")
		{
			collectionOptionSyntax="storageEngine :"+storageEngine.Notes;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var validator as EA.TaggedValue
		validator=Mongo_Element.TaggedValues.GetByName("validator");
		if(validator!=null&&validator.Notes!="")
		{
			collectionOptionSyntax="validator :"+validator.Notes;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var validationLevel as EA.TaggedValue
		validationLevel=Mongo_Element.TaggedValues.GetByName("validationLevel");
		if(validationLevel!=null&&validationLevel.Value!="")
		{
			collectionOptionSyntax="validationLevel :"+validationLevel.Value;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var validationAction as EA.TaggedValue
		validationAction=Mongo_Element.TaggedValues.GetByName("validationAction");
		if(validationAction!=null&&validationAction.Value!="")
		{
			collectionOptionSyntax="validationAction :"+validationAction.Value;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var indexOptionDefaults as EA.TaggedValue
		indexOptionDefaults=Mongo_Element.TaggedValues.GetByName("indexOptionDefaults");
		if(indexOptionDefaults!=null&&indexOptionDefaults.Notes!="")
		{
			collectionOptionSyntax="indexOptionDefaults :"+indexOptionDefaults.Notes;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var viewOn as EA.TaggedValue
		viewOn=Mongo_Element.TaggedValues.GetByName("viewOn");
		if(viewOn!=null&&viewOn.Value!="")
		{
			collectionOptionSyntax="viewOn :"+viewOn.Value;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var pipeline as EA.TaggedValue
		pipeline=Mongo_Element.TaggedValues.GetByName("pipeline");
		if(pipeline!=null&&pipeline.Notes!="")
		{
			collectionOptionSyntax="pipeline :"+pipeline.Notes;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		var writeConcern as EA.TaggedValue
		writeConcern=Mongo_Element.TaggedValues.GetByName("writeConcern");
		if(writeConcern!=null&&writeConcern.Notes!="")
		{
			collectionOptionSyntax="writeConcern :"+writeConcern.Notes;
			collectionOptions.push(collectionOptionSyntax);
		}
		
		//timeseries field
		var timeseriesArray=[];
		var timeField as EA.TaggedValue
		timeField=Mongo_Element.TaggedValues.GetByName("timeField");
		if(timeField!=null&&timeField.Value!="")
			timeseriesArray.push(timeField)
		
		var metaField as EA.TaggedValue
		 metaField=Mongo_Element.TaggedValues.GetByName("metaField");
		if(metaField!=null&&metaField.Value!="")
			timeseriesArray.push(metaField)
		
		var granularity as EA.TaggedValue
		granularity=Mongo_Element.TaggedValues.GetByName("granularity");
		if(granularity!=null&&granularity.Value!="")
			timeseriesArray.push(granularity)
		
		var bucketMaxSpanSeconds as EA.TaggedValue
		bucketMaxSpanSeconds=Mongo_Element.TaggedValues.GetByName("bucketMaxSpanSeconds");
		if(bucketMaxSpanSeconds!=null&&bucketMaxSpanSeconds.Value!="")
			timeseriesArray.push(bucketMaxSpanSeconds)
		
		var bucketRoundingSeconds as EA.TaggedValue
		bucketRoundingSeconds=Mongo_Element.TaggedValues.GetByName("bucketRoundingSeconds");
		if(bucketRoundingSeconds!=null&&bucketRoundingSeconds.Value!="")
			timeseriesArray.push(bucketRoundingSeconds)
		
		if(timeseriesArray.length != 0)
		{
			var timeSeriesSyntax="";
			 timeSeriesSyntax +="timeseries :\n \t{";
			for (var j=0; j<timeseriesArray.length;j++)
			{
				var timeseriestag as EA.TaggedValue
				timeseriestag=timeseriesArray[j];
				if(timeseriestag.Name=="bucketMaxSpanSeconds"||timeseriestag.Name=="bucketRoundingSeconds")
				{
					timeSeriesSyntax +=" \n"+timeseriestag.Name+": "+timeseriestag.Value;
				}
				else
					timeSeriesSyntax +=" \n"+timeseriestag.Name+": \""+timeseriestag.Value+"\"";
				 if (timeseriesArray.length-1!=j)
				 {
					timeSeriesSyntax+= ",";
				 }							 
			}
			timeSeriesSyntax+="\n \t}";
			collectionOptions.push(timeSeriesSyntax);
			
		}
		
		var expireAfterSeconds as EA.TaggedValue
		expireAfterSeconds=Mongo_Element.TaggedValues.GetByName("expireAfterSeconds");
		if(expireAfterSeconds!=null&&expireAfterSeconds.Value!="")
		{
			collectionOptionSyntax="expireAfterSeconds :"+expireAfterSeconds.Value; 
			collectionOptions.push(collectionOptionSyntax);
		}
		
		//clusterdIndex
		var clusteredIndexArray=[]
		var key as EA.TaggedValue
		key=Mongo_Element.TaggedValues.GetByName("ClusteredIndexKey");
		if(key!=null&&key.Notes!="")
			clusteredIndexArray.push(key)
		
		var unique as EA.TaggedValue
		unique=Mongo_Element.TaggedValues.GetByName("ClusteredIndexUnique");
		if(unique!=null && unique.Value == "True" )
			clusteredIndexArray.push(unique)
		
		var name as EA.TaggedValue
		name=Mongo_Element.TaggedValues.GetByName("ClusteredIndexName");
		if(name!=null&&name.Value!="")
			clusteredIndexArray.push(name)
		
		if(clusteredIndexArray.length!=0)
		{
			var clusterIndexSyntax="";
			clusterIndexSyntax +="clusteredIndex :\n \t{ ";
			for (var k=0; k<clusteredIndexArray.length;k++)
			{
				
				var clusteredindextag as EA.TaggedValue
				clusteredindextag=clusteredIndexArray[k];
			  switch (clusteredindextag.Name)
				{
					case "ClusteredIndexKey":
						clusterIndexSyntax +="\nkey :"+clusteredindextag.Notes;
					break;
					case "ClusteredIndexName":
						clusterIndexSyntax +="\n name : \""+clusteredindextag.Value+"\"";
					break;
					case "ClusteredIndexUnique":
						clusterIndexSyntax +=" \n unique : true";
					break;
				}
				
				 if (clusteredIndexArray.length-1!=k)
				 {
					clusterIndexSyntax+= ",";
				 }							 
			}
			clusterIndexSyntax+="\n \t}";
			
			collectionOptions.push(clusterIndexSyntax);
		}
		
		if(collectionOptions!=null&&collectionOptions.length>0)
		{
			create_document+=",\n{\n"
			for(var y=0;y<collectionOptions.length;y++)
			{
				create_document+=collectionOptions[y]
				if(y!=collectionOptions.length-1)
				{
					create_document+=",\n"
				}
			}
			create_document+="\n}\n";
		}
		create_document +=");\n\n" ;
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}	
	
	return create_document;
}

function Check_Insert(Mongo_Element)
{	
	var rows=[];
	
	try
	{
		var manyfield=[];
		
		for(var k=0;k<Mongo_Element.Attributes.Count;k++)
		{
			var t=Mongo_Element.Attributes.GetAt(k);
			if(!manyfield.includes(t.Name))
			{
				var attributeName=t.Name;
				 manyfield.push(attributeName);
			}			
		}
		
		for(var k=0;k<manyfield.length;k++)
		{
			var fields=[];
			var attribute as EA.TaggedValue
			for(var h=0;h<Mongo_Element.Attributes.Count;h++)
			{
				 attribute=Mongo_Element.Attributes.GetAt(h);
				if(manyfield[k]==attribute.Name)
				{
					fields.push(attribute);
				}				
		   }
		   rows.push(fields);
		}
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}

	
	return rows
}

function createindex(Mongo_Element,operation)
{
	var indexquery="";
	
	try
	{
		var isSearchIndex as EA.TaggedValue;
		isSearchIndex=operation.TaggedValues.GetByName("isSearchIndex");
		if(isSearchIndex!=null && isSearchIndex.Value=="True")
		{
			indexquery += createsearchindex(Mongo_Element,operation) ;
		}
		else
		{
		
			indexquery+="db."+Mongo_Element.Name+".createIndex(\n";
			var keys as EA.TaggedValue
				keys=operation.TaggedValues.GetByName("Keys");
			if(keys !=null && keys.Notes!="")
			{
				indexquery+=keys.Notes+"\n";
			}
			IndexOptions=[];
			IndexOptionSyntax="";
			var Unique as EA.TaggedValue
				Unique=operation.TaggedValues.GetByName("Unique");
			if(Unique !=null&&(Unique.Value==1 || Unique.Value == "True"))
			{
				IndexOptionSyntax="unique : true";
				IndexOptions.push(IndexOptionSyntax);
			}
			
			// text index tags
			 var defaultLanguage as EA.TaggedValue
			defaultLanguage=operation.TaggedValues.GetByName("defaultLanguage");
			if(defaultLanguage !=null&&defaultLanguage.Value!="")
			{
				IndexOptionSyntax= "default_language : "+defaultLanguage.Value;
				IndexOptions.push(IndexOptionSyntax);
			}

			 var languageOverride as EA.TaggedValue
			languageOverride=operation.TaggedValues.GetByName("language Override");
			if(languageOverride !=null&&languageOverride.Value!="")
			{
				IndexOptionSyntax="language_override : "+languageOverride.Value;
				IndexOptions.push(IndexOptionSyntax);
			}

			 var weights as EA.TaggedValue
			weights=operation.TaggedValues.GetByName("weights");
			if(weights !=null&&weights.Notes!="")
			{
				IndexOptionSyntax ="weights : "+weights.Notes;
				IndexOptions.push(IndexOptionSyntax);
			}

			 var textIndexVersion as EA.TaggedValue
			textIndexVersion=operation.TaggedValues.GetByName("textIndexVersion");
			if(textIndexVersion !=null&&textIndexVersion.Value!="")
			{
				IndexOptionSyntax="textIndexVersion : "+textIndexVersion.Value;
				IndexOptions.push(IndexOptionSyntax);
			}


			 var wildcardProjection as EA.TaggedValue
			wildcardProjection=operation.TaggedValues.GetByName("wildcardProjection");
			if(wildcardProjection !=null&&wildcardProjection.Notes!="")
			{
				IndexOptionSyntax="wildcardProjection : "+wildcardProjection.Notes;
				IndexOptions.push(IndexOptionSyntax);
			}

			//2dsphere tags
			var sphereIndexVersion as EA.TaggedValue
			sphereIndexVersion=operation.TaggedValues.GetByName("2dsphereIndexVersion");
			if(sphereIndexVersion !=null&&sphereIndexVersion.Value!="")
			{
				IndexOptionSyntax ="\"2dsphereIndexVersion\" : "+sphereIndexVersion.Value;
				IndexOptions.push(IndexOptionSyntax);
			}
			//2d tags
			var bits as EA.TaggedValue
			bits=operation.TaggedValues.GetByName("bits");
			if(bits !=null&&bits.Value!="")
			{
				IndexOptionSyntax ="bits : "+bits.Value;
				IndexOptions.push(IndexOptionSyntax);
			}
			var min as EA.TaggedValue
			min=operation.TaggedValues.GetByName("min");
			if(min !=null&&min.Value!="")
			{
				IndexOptionSyntax ="min : "+min.Value;
			}

			var max as EA.TaggedValue
			max=operation.TaggedValues.GetByName("max");
			if(max !=null&&max.Value!="")
			{
				IndexOptionSyntax ="max : "+max.Value;
				IndexOptions.push(IndexOptionSyntax);
			}


			var StorageEngine as EA.TaggedValue
			StorageEngine=operation.TaggedValues.GetByName("StorageEngine");
			if(StorageEngine !=null&&StorageEngine.Value!="")
			{
				IndexOptionSyntax ="storageEngine : "+StorageEngine.Value;
				IndexOptions.push(IndexOptionSyntax);
			}

			var PartialFilterExpression as EA.TaggedValue
			PartialFilterExpression=operation.TaggedValues.GetByName("PartialFilterExpression");
			if(PartialFilterExpression !=null&&PartialFilterExpression.Notes!="")
			{
				IndexOptionSyntax="partialFilterExpression : "+ PartialFilterExpression.Notes;
				IndexOptions.push(IndexOptionSyntax);
			}

			var expireAfterSeconds as EA.TaggedValue
			expireAfterSeconds=operation.TaggedValues.GetByName("ExpireAfterSeconds");
			if(expireAfterSeconds !=null&&expireAfterSeconds.Value!="")
			{
				IndexOptionSyntax ="expireAfterSeconds : " +expireAfterSeconds.Value;
				IndexOptions.push(IndexOptionSyntax);
			}

			var collation as EA.TaggedValue
			collation=operation.TaggedValues.GetByName("Collation");
			if(collation !=null&&collation.Notes!="")
			{
				IndexOptionSyntax="collation : "+collation.Notes;
				IndexOptions.push(IndexOptionSyntax);
			}

			if(IndexOptions!=null&&IndexOptions.length>0)
			{
				indexquery+=",\n{\n "
				for(var y=0;y<IndexOptions.length;y++)
				{
					indexquery+=IndexOptions[y]
					if(y!=IndexOptions.length-1)
					{
						indexquery+=",\n"
					}
				}
				
				indexquery +="\n}";
			}
			
			var commitquorum as EA.TaggedValue
			commitquorum=operation.TaggedValues.GetByName("commitquorum");
			if(commitquorum !=null&&commitquorum.Value!="")
			{
				indexquery +=  ","+commitquorum.Value ;
			}
			
			indexquery += "\n);\n\n";
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
	
	return indexquery;
}

function insertmethod(Mongo_Element)
{
	var insertquery="";
	
	try
	{
		var Rows= Check_Insert(Mongo_Element);
		var columnslength=Rows[0];
				
		var subfield as EA.TaggedValue;
		
		if(columnslength.length==1)
		{

			insertquery+="db."+Mongo_Element.Name+".insertOne( {\n";

			for(var j=0;j<Mongo_Element.Attributes.Count;j++)
			{
				var field as EA.Attribute
				field=Mongo_Element.Attributes.GetAt(j);
				insertquery += field.Name+" : " ;

				var fieldvalue as EA.TaggedValue
				fieldvalue=field.TaggedValues.GetByName("FieldValue");
				
				if(fieldvalue!=null&&fieldvalue.Value!="")
					insertquery += fieldvalue.Value ;
				else
				{
					subfield = field.TaggedValues.GetByName("SubField");
					insertquery += subfield.Notes ;
				}

				if(Mongo_Element.Attributes.Count-1!=j)
					insertquery += ",\n";					
			}

			insertquery+="\n}\n);\n\n";
		}
		else
		{
			insertquery+="db."+Mongo_Element.Name+".insertMany([\n";

			for(var k=0;k<columnslength.length;k++)
			{
				insertquery+="{";						
				for(var j=0;j<Rows.length;j++)
				{
					var columns=Rows[j];
					var attribute as EA.Attribute
					attribute=columns[k];
					
					var fieldvalue as EA.TaggedValue
					fieldvalue=attribute.TaggedValues.GetByName("Fieldvalue");
					
					if(fieldvalue!=null&&fieldvalue.Value!="")
						insertquery+=attribute.Name+" : "+fieldvalue.Value;
					
					subfield=attribute.TaggedValues.GetByName("SubField");
					
					if(subfield!=null&&subfield.Notes!="")
						insertquery+=attribute.Name+" : "+subfield.Notes
					
					if(j!=Rows.length-1)
						insertquery+=",";
				}

				if(k != columnslength.length-1)
					insertquery+="},\n";
				else 
					insertquery+="}\n";

			}
			insertquery+="]);\n\n";
		}		
		
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		
	return insertquery
}

function createsearchindex(Mongo_Element,operation)
{
	var indexquery="";
	
	try
	{
		indexquery+="db."+Mongo_Element.Name+".createSearchIndex(\n";
		indexquery+="\""+operation.Name+"\" " ;
		var index_def as EA.TaggedValue
		index_def=operation.TaggedValues.GetByName("Index Definition");
		if(index_def!=null&index_def.Notes!="")
		{
			indexquery+=" , \n { " +index_def.Notes+" } ) ;\n\n" ;
		}
	}
	catch(e)
	{
		Session.Output("Message :"+ e.message+"\n")
		Session.Output("Stack Trace : " +e.stack+" \n\n" );	
	}
		return indexquery;
}
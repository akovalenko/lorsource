<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.net.URLEncoder,java.sql.Connection"   buffer="60kb"%>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="ru.org.linux.site.*" %>
<%@ page import="ru.org.linux.util.ServletParameterParser" %>
<% Template tmpl = Template.getTemplate(request); %>
<jsp:include page="/WEB-INF/jsp/head.jsp"/>

<%
  int msgid = new ServletParameterParser(request).getInt("msgid");

  String redirectUrl = tmpl.getMainUrl() + "view-message.jsp?msgid=" + msgid;
  StringBuffer options = new StringBuffer();

  if (request.getParameter("page") != null) {
    options.append("&page=");
    options.append(URLEncoder.encode(request.getParameter("page")));
  }

  if (request.getParameter("back") != null) {
    options.append("&back=");
    options.append(URLEncoder.encode(request.getParameter("back")));
  }

  if (request.getParameter("nocache") != null) {
    options.append("&nocache=");
    options.append(URLEncoder.encode(request.getParameter("nocache")));
  }

  if (request.getParameter("cid") != null) {
    Connection db = null;
    int cid = new ServletParameterParser(request).getInt("cid");

    try {
      db = LorDataSource.getConnection();
      Message topic = new Message(db, msgid);
      CommentList comments = CommentList.getCommentList(db, topic, false);
      CommentNode node = comments.getNode(cid);
      if (node == null) {
        throw new MessageNotFoundException(cid, "��������� #" + cid + " ���� ������� ��� �� ����������");
      }

      int pagenum = comments.getCommentPage(node.getComment(), tmpl);

      if (pagenum > 0) {
        options.append("&page=");
        options.append(pagenum);
      }

      options.append("#");
      options.append(cid);
    } finally {
      if (db != null) {
        db.close();
      }
    }
  }

  response.setHeader("Location", redirectUrl + options.toString());
  response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);
%>
<jsp:include page="WEB-INF/jsp/header.jsp"/>
Go to: <%= redirectUrl %>
<jsp:include page="WEB-INF/jsp/footer.jsp"/>

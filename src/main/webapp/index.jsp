<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>跳转到主页</title>
</head>
<body>
<!-- 这里的index.jsp并不是真正的主页， 系统的所有页面都放在 WEB-INF/pages下，这样用户就无法对这些页面直接访问-->
<jsp:forward page="/chat/loginpage"></jsp:forward>
</body>
</html>
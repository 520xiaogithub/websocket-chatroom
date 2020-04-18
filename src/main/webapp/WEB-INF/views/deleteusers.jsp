<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<!-- 引入easyUI 外部头文件 -->
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/themes/default/easyui.css" />
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/themes/icon.css" />

<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/jquery.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/jquery.easyui.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-easyui-1.4.1/locale/easyui-lang-zh_CN.js"></script>
<!-- <script type="text/javascript" src="/js/common.js"></script> -->
<title>跳转到主页</title>

<!-- 使用js动态生成数据表格 -->
<script type="text/javascript">
function doDelete(){
	//删除选中用户
	$('#delStaffWindow').window("open");
}

//定义删除用户窗口的大小
$('#delStaffWindow').window({
	        title: '删除用户',
	        width: 400,
	        modal: true,
	        shadow: true,
	        closed: true,
	        height: 400,
	        resizable:false
	    });

$(function(){
	//数据表格
	$("#grid").datagrid({
		url:"data.txt",
		rownumbers:true,
		pagination:true,
		//表头信息
		columns:[[
			{
				title:'选择框',
				field:'checkbox',
				checkbox:true
			},
			{
				title:'编号',
				field:'id',
				width:200,
				align : 'center'		
			},
			{
				title:'用户名',
				field:'nickname',
				width:200,
				align : 'center'
			}
		]],
		//定义toolbar
		toolbar:[
			{
				id:'cancel',
				text:'删除',
				iconCls:'icon-cancel',
				width:'100',
				height:'30',
				handler:function(){
					$.messager.confirm('消息','确认要删除吗？',function(data){
						if(data){
							doDelete();
						}
					});	
				}
			}
		]
	});
	
});
</script>

</head>
<body>
	<!-- 加载远程json格式数据 -->
	<table id="grid"></table>
	
</body>
</html>
package com.kedacom.chartroom.web.controller;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import utils.GsonUtils;

import com.kedacom.chartroom.domain.Message;
import com.kedacom.chartroom.domain.User;
import com.kedacom.chartroom.service.MessageService;
import com.kedacom.chartroom.service.UserService;


@Controller
@RequestMapping("/chat")
public class ChatController {
    
    @Autowired
    public UserService userService;
    //保存所有登录用户对象,键是用户id
    Map<Integer, User> loginUserObjects = new HashMap<Integer, User>();
    
    //查找出所有在线用户
    @RequestMapping(value = "/findAllOnlineUser", method = RequestMethod.POST)
    public void findAllOnlineUser(HttpServletRequest request, HttpServletResponse response) throws IOException{
        //获取到当前登录的用户id
    	int loginId = Integer.parseInt(request.getParameter("id"));
        //HttpSession session = request.getSession();
    	//获取到当前登录的用户对象
        User user = loginUserObjects.get(loginId);
        
        List<User> usersList=new ArrayList<User>();
        usersList =userService.getAllOnlineUser(user);
        System.out.println("所有在线用户是:_________________"+usersList);
        //将对象转换为Json格式
        String jsonData=GsonUtils.toJson(usersList);
        System.out.println("json格式:_________________"+jsonData);
        //将Json数据放入response对象中
        //设置response返回数据格式为Json
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().print(jsonData);
        
    }
    
    //用户退出跳转
    @RequestMapping(value = "/quit", method = RequestMethod.GET)
    public ModelAndView quit(HttpServletRequest request) {
    	HttpSession session = request.getSession();
	    int loginId = Integer.parseInt(request.getParameter("id"));
	    //获取到当前登录的用户对象
	    User loginUser=loginUserObjects.get(loginId);
	    if(session != null && loginUser != null){
	        //修改用户的状态state为0
	        loginUser.setState(0);
	        userService.modifyUserStateById(loginUser);
	        //删除map中对应的键值对
	        loginUserObjects.remove(loginId);
	        session.invalidate();            	        
	    }
	    
        return new ModelAndView("redirect:loginpage");   //重定向
    }
	// 跳转到登录页面
	@RequestMapping(value = "/loginpage", method = RequestMethod.GET)
	public ModelAndView loginpage(HttpServletRequest request) {
	    //测试数据&&&&&&&&&&&&&&&&&&&&&&&&&&&&************************************
//	    User user1 = new User(1,"xiao","1111",0);
//	    User user2 = new User(2,"hua","2222",1);
//	    List<User> list = new ArrayList<User>();
//	    list.add(user1);
//	    list.add(user2);
//	    //将对象转换为JSon格式
//	    String jsonData=GsonUtils.toJson(list);
//	    System.out.println("Json格式的数据：________________________"+jsonData);
	    
	    
	    HttpSession session = request.getSession();
	    if(session.getAttribute("msg") != null){
            session.removeAttribute("msg");
        }
		return new ModelAndView("login");
	}
	
	//登录窗口中注册按钮的跳转
	 @RequestMapping(value = "/regist", method = RequestMethod.GET)
	    public ModelAndView regist(){
		 return new ModelAndView("regist");
	    }
	 
	 //检测用户名是否存在
	    @RequestMapping(value = "/judgeUserNameIsExit", method = RequestMethod.POST)
	    public void judgeUserNameIsExit(HttpServletRequest request, HttpServletResponse response) throws IOException{
	        String result="";
	        //解决请求乱码问题
	        request.setCharacterEncoding("utf-8");
	        String username=request.getParameter("nickname");
	        //查询数据库
	        User userS = userService.findByUserName(username);
	        
	        if(userS != null){
	            //提醒用户该用户名已经存在
	           result="<font color='red'>该用户名已经存在，请重新输入！</font>";
	        }
	        //解决响应乱码问题
	        response.setContentType("text/html; charset=UTF-8");
	        response.getWriter().print(result);

	    }
	 
	// 用户注册页面
	@RequestMapping(value = "/doRegist", method = RequestMethod.POST)
	public String doRegist(HttpServletRequest request){
		//首先判断用户名是否存在
//	    System.out.println("########################"+userService.findByUserName(request.getParameter("nickname")));
	    if(userService.findByUserName(request.getParameter("nickname"))!=null){	        

	    }
	    
	   User user=new User();
	  //如果用户名不存在，则进行数据存储  
        user.setNickname(request.getParameter("nickname"));
        user.setPassword(request.getParameter("password"));
        //用户初始未登录状态默认为  0
        user.setState(0);
        user.setSign(0);
        
      //保存用户信息到数据库中
        int flag=userService.insertUser(user);
        if(flag<0){
          //表示注册失败
            System.out.println("返回前端显示，注册失败！");   //----------------------------------
            return "fail";
        }
        
      //表示注册成功
        System.out.println("返回前端显示，注册成功！");
        return "success";
	}
	
	//登录前，判断该登录用户是否已经登录
	@RequestMapping(value = "/judge", method = RequestMethod.POST)
	public void judge(HttpServletRequest request, HttpServletResponse response) throws IOException{
	    String result="";
	    //解决请求乱码问题
	    request.setCharacterEncoding("utf-8");
	    String username=request.getParameter("nickname");
	    //查询数据库，返回一个用户状态state
	    User userS = userService.findByUserName(username);
	    if(userS==null) {
	    	//提醒用户该用户名已经登录
		       result="<font color='red'>该用户名不存在！</font>";
	    }else {
	    	
	    	int userState = userS.getState();
		    if(userState==1){
		        //提醒用户该用户名已经登录
		       result="<font color='red'>该用户已经登录！</font>";
		    }
	    }
	    
	    //解决响应乱码问题
	    response.setContentType("text/html; charset=UTF-8");
	    response.getWriter().print(result);
	    
	}
	
	
	//用户登录失败时的跳转
	@RequestMapping(value = "/failToLogin", method = RequestMethod.POST)
    public ModelAndView failToLogin() {
	    
        return new ModelAndView("login");
    }

	// 登录进入聊天主页面
	@RequestMapping(value = "/login", method = RequestMethod.POST)
	public ModelAndView login(HttpServletRequest request, HttpServletResponse response) throws IOException {
		   
	    HttpSession session = request.getSession();
	    //首先判断用户输入的验证码是否正确
	    //获取用户输入验证码
	    String userInputInvalidateCode = request.getParameter("checkImg");
	    //获取图片中的验证码
	    String imgInvalidateCode = (String)session.getAttribute("servletImg");
	    
		//登录操作
		User loginUser=new User();

	      //如果用户名不存在，则进行数据存储  
		loginUser.setNickname(request.getParameter("nickname"));
		loginUser.setPassword(request.getParameter("password"));
	        //用户初始未登录状态默认为  0
		loginUser.setState(1);
		//从后端查询获取当前登录用户id
	    int id = (int)userService.login(loginUser);
	    
		//向用户返回，登录失败的提示
	    if(id==-1 || ! userInputInvalidateCode.equalsIgnoreCase(imgInvalidateCode)){
	        if(id==-1) {
	        	
	        	session.setAttribute("msg", "用户名或密码错误!");
	        	return new ModelAndView("forward:failToLogin");
	        }else {
	        	
	        	session.setAttribute("msg", "验证码错误");
		    	return new ModelAndView("forward:failToLogin");
	        }
	        
	    }else{
	        //清空session中的msg数据
	       // System.out.println(session.getAttribute("msg")+"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
	        if(session.getAttribute("msg") != null){
	            session.removeAttribute("msg");
	        }
	        
	        loginUser.setId(id);        //这里的id需要从数据库中获取----------------------------
	      //保存当前登录用户到map集合
		    loginUserObjects.put(id, loginUser);
	        //更新用户状态
	        userService.modifyUserStateById(loginUser);
	        // 将用户放入session
	        session.setAttribute("loginUser", loginUser);
	        
	        // 将登录信息放入数据库，便于协查跟踪聊天者
	        System.out.println("新用户诞生了：" + loginUser);
	        return new ModelAndView("redirect:mainpage");
	    }
	    
	}
	
	// 跳转到聊天室页面
	@RequestMapping(value = "/mainpage", method = RequestMethod.GET)
	public ModelAndView mainpage(HttpServletRequest request) {
		//判断，如果没有session，则跳到登录页面
		HttpSession session = request.getSession();
		if(null==session.getAttribute("loginUser")){
			return new ModelAndView("login");
		}else{
			return new ModelAndView("main");
		}
	}
	
	//实现文件上传upload
	@RequestMapping(value = "/upload", method = RequestMethod.POST)
	@ResponseBody
	public void upload(@RequestParam(value = "file", required = false) MultipartFile file, HttpServletRequest request, HttpServletResponse response) throws IOException {
		
		//解决响应乱码问题
		response.setCharacterEncoding("utf-8");
	    response.setContentType("application/json; charset=UTF-8");
	 
		Calendar currTime = Calendar.getInstance();
        String time = String.valueOf(currTime.get(Calendar.YEAR))+String.valueOf((currTime.get(Calendar.MONTH)+1));
        String path ="d:"+File.separator+"img"+File.separator+time;   //保存的文件位置是d:\img\time——当前年月的时间
        
        String suffix = file.getOriginalFilename().substring(file.getOriginalFilename().lastIndexOf("."));
        //System.out.println(file.getOriginalFilename()+"     这个为上传的文件名");
        suffix = suffix.toLowerCase();
        if(suffix.equals(".xls") || suffix.equals(".doc") || suffix.equals(".txt") || suffix.equals(".pdf") || suffix.equals(".docx") || suffix.equals(".xlsx") || suffix.equals(".caj") || suffix.equals(".xml") || suffix.equals(".zip") || suffix.equals(".rar") || suffix.equals(".mp4") || suffix.equals(".avi") || suffix.equals(".mp3")){
            //String fileName = UUID.randomUUID().toString()+suffix;
        	String fileName = file.getOriginalFilename();
            File targetFile = new File(path, fileName);     //path+fileName为文件的存储路径
            String fileURLAddr = path+"\\"+fileName;
                      
            if(!targetFile.getParentFile().exists()){      //注意，判断父级路径是否存在
                targetFile.getParentFile().mkdirs();
            }
            long size = 0;
            //保存
            try {
                file.transferTo(targetFile);
                size = file.getSize();
            } catch (Exception e) {
                e.printStackTrace();
            }
            //文件上传成功
            Message msg = new Message();
            msg.setText("true");
            msg.setFileURL(fileURLAddr);
            response.getWriter().write(GsonUtils.toJson(msg));
        }else{
        	//文件上传失败
            Message msg = new Message();
            msg.setText("false");
            response.getWriter().write(GsonUtils.toJson(msg));
        }
	}
	
	//管理员剔除在线用户deleteSelectUsers
	@RequestMapping(value = "/deleteSelectUsers", method = RequestMethod.POST)
    public void deleteSelectUsers(HttpServletRequest request, HttpServletResponse response) throws IOException{
		//获取前端传递过来的参数信息
		String ids= request.getParameter("ids");
		System.out.println("ids==========================="+ids);
		
		//结果map
				Map<String, Object> resultMap = new HashMap<String, Object>();
				
				try {
					//调用业务层
					userService.deleteSelectOnlineUser(ids);
					resultMap.put("result", true);
				} catch (Exception e) {
					resultMap.put("result", false);
					e.printStackTrace();
				}
				
				//返回json结果给前端
				String jsonData2=GsonUtils.toJson(resultMap);
				//将Json数据放入response对象中
		        //设置response返回数据格式为Json
		        response.setContentType("application/json; charset=UTF-8");
		        response.getWriter().print(jsonData2);
    }
	
	
	//实现图片上传upload
	@RequestMapping(value = "/uploadImg", method = RequestMethod.POST)
	@ResponseBody
	public void uploadImg(@RequestParam(value = "image", required = false) MultipartFile image, HttpServletRequest request, HttpServletResponse response) throws IOException {
		
		//解决响应乱码问题
		response.setCharacterEncoding("utf-8");
	    response.setContentType("application/json; charset=UTF-8");
	 
		Calendar currTime = Calendar.getInstance();
        String time = String.valueOf(currTime.get(Calendar.YEAR))+String.valueOf((currTime.get(Calendar.MONTH)+1));
        String path ="d:"+File.separator+"img"+File.separator+time;   //保存的文件位置是d:\img\time——当前年月的时间
        String suffix = image.getOriginalFilename().substring(image.getOriginalFilename().lastIndexOf("."));
        //System.out.println(file.getOriginalFilename()+"     这个为上传的文件名");
        suffix = suffix.toLowerCase();
        if(suffix.equals(".png") || suffix.equals(".jpeg") || suffix.equals(".gif") || suffix.equals(".jpg")){
            //String fileName = UUID.randomUUID().toString()+suffix;
        	String fileName = image.getOriginalFilename();
            File targetFile = new File(path, fileName);     //path+fileName为文件的存储路径
            String fileURLAddr = path+"\\"+fileName;
                      
            if(!targetFile.getParentFile().exists()){      //注意，判断父级路径是否存在
                targetFile.getParentFile().mkdirs();
            }
            long size = 0;
            //保存
            try {
            	image.transferTo(targetFile);
                size = image.getSize();
            } catch (Exception e) {
                e.printStackTrace();
            }
            //文件上传成功
            Message msg = new Message();
            msg.setText("true");
            msg.setFileURL(fileURLAddr);
            response.getWriter().write(GsonUtils.toJson(msg));
        }else{
        	//文件上传失败
            Message msg = new Message();
            msg.setText("false");
            response.getWriter().write(GsonUtils.toJson(msg));
        }
	}

}
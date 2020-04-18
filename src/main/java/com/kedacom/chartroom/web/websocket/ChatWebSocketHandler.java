package com.kedacom.chartroom.web.websocket;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.BinaryMessage;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.WebSocketMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.util.HtmlUtils;

import utils.GsonUtils;

import com.kedacom.chartroom.domain.Message;
import com.kedacom.chartroom.domain.User;
import com.kedacom.chartroom.service.MessageService;
import com.kedacom.chartroom.service.UserService;


/**
 * 
 * 说明：WebSocket处理器
 * <p>主题：UserService.java</p>
 * <p>内容描述：</p>
 * <p>版权：Copyright(C) 2019</p>
 * <p>公司：www.kedacom.com</p>
 * @author 沈华理
 * @date 2019年4月16日
 * 
 */
@Component("chatWebSocketHandler")
public class ChatWebSocketHandler implements WebSocketHandler{         //implements WebSocketHandler    以下所有方法都是握手成功之后自动调用####################################
	
	@Autowired
	private MessageService messageService;
	@Autowired
    public UserService userService;
	
	//在线用户的SOCKETsession(存储了所有的通信通道)
	public static final Map<String, WebSocketSession> USER_SOCKETSESSION_MAP;
	
	
	//******文件传输代码*************************************************************************************
	SimpleDateFormat format=new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");  //设置发送消息日期
	FileOutputStream output;
	//获取文件单发的fromId和toId
	String fromId ;
	String toId ;
	String fromName;
	Message temptemp;
	int fileAndFalg =0;  //文件是否上传完毕标记
	String MessageURLURL;  //保存文件上传的地址
	int MessageId;  //保存消息在数据库中的id
	String idsss;   //保存强制下线的用户id
	String userNamesss;  //保存强制下线用户的虚拟用户名，用于对其他用户进行提示
	
	//存储所有的在线用户
	static {
		USER_SOCKETSESSION_MAP = new HashMap<String, WebSocketSession>();
	}
	
	/**
	 * webscoket建立好链接之后的处理函数--连接建立后的准备工作
	 */
	//这个方法是每个用户成功建立WebSocket连接之后都要执行的
	@Override
	public void afterConnectionEstablished(WebSocketSession webSocketSession) throws Exception {
		//将当前的连接的用户会话放入MAP,key是用户编号
		User loginUser=(User) webSocketSession.getAttributes().get("loginUser");
		//System.out.println(loginUser.getId()+1+"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$@@@@@@@@@@@@@@@@@@@@@@@");
		//id为Integer类型
		//转换Integer.toString(loginUser.getId())
		USER_SOCKETSESSION_MAP.put(Integer.toString(loginUser.getId()), webSocketSession);
	
		//群发消息告知大家
		Message msg = new Message();
		msg.setText("【"+loginUser.getNickname()+"】已经上线啦，大家欢迎！");
		msg.setDate(new Date());
		//获取所有在线的WebSocketSession对象集合
		Set<Entry<String, WebSocketSession>> entrySet = USER_SOCKETSESSION_MAP.entrySet();
		//将最新的所有的在线人列表放入消息对象的list集合中，用于页面显示
		for (Entry<String, WebSocketSession> entry : entrySet) {
			msg.getUserList().add((User)entry.getValue().getAttributes().get("loginUser"));
		}
		
		//将消息转换为json
		TextMessage message = new TextMessage(GsonUtils.toJson(msg));
		//群发消息
		sendMessageToAll(webSocketSession, message);
		
	}
	
	
	@Override
	/**
     * 客户端发送服务器的消息时的处理函数，在这里收到消息之后可以分发消息
     */
	//处理消息：当一个新的WebSocket到达的时候，会被调用（在客户端通过Websocket API发送的消息会经过这里，然后进行相应的处理）
	public void handleMessage(WebSocketSession webSocketSession, WebSocketMessage<?> message) throws Exception {
	    
	    System.out.println(message.getPayload().toString()+"{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{");
		System.out.println(message.getClass().getName()+"message.getClass().getName()");
		//如果消息没有任何内容，则直接返回
		if (message.getPayloadLength()==0)return;
		
		String payload=(String) message.getPayload();   //获取请求参数
		System.out.println("payload.endsWith(:fileFinishSingle)=      "+payload.endsWith(":fileFinishSingle"));
		
		if(! (payload.endsWith(":fileFinishSingle") || payload.endsWith(":deleteSelectUser"))) {
		    temptemp = GsonUtils.fromJson(message.getPayload().toString(), Message.class);
		}	
		
		if(payload.endsWith(":deleteSelectUser")) {
			//将用户强制断开连接
			//进行字符串截取
			String strSub = payload.substring(0, payload.lastIndexOf(":deleteSelectUser"));
			//分割字符串
			String[] idsArray = strSub.split(",");
			//删除用户
			for (String id : idsArray) {
				idsss = id;
				userNamesss = "发不良信息和言语的用户已被管理员剔除";
				final CloseStatus closeStatus = CloseStatus.NORMAL;    //closeStatus=1000
				afterConnectionClosed(webSocketSession, closeStatus);
			}
		
		}else if(payload.endsWith(":fileFinishSingle")){

            //判断是群发还是单发
            if(! toId.equals("-1")) {     //单发
            	//设置文件上传路径
            	MessageURLURL=payload.substring(0, payload.lastIndexOf(":fileFinishSingle"));
                sendFileMessageToUser(webSocketSession, fromId, toId, message);
                
            }else {    //群发
            	//设置文件上传路径
            	MessageURLURL=payload.substring(0, payload.lastIndexOf(":fileFinishSingle"));
                sendFileMessageToAll(webSocketSession, message);
                
            }
        }else if(temptemp.getTypeName().equals("file")){
        	//向数据库中保存消息数据
            fromId = Integer.toString(temptemp.getFromID());
            toId = Integer.toString(temptemp.getToID());
            fromName = temptemp.getFromName();
            Message messageSave = new Message();
            messageSave.setDate(new Date());
            messageSave.setTypeName(temptemp.getTypeName());
            messageSave.setFromID(temptemp.getFromID());
            messageSave.setFromName(temptemp.getFromName());
            messageSave.setToID(temptemp.getToID());
//            messageSave.setFileURL("null");
//            messageSave.setText("null");
            
            MessageId = messageService.insertMessage(messageSave);   //该消息在数据库中的id         
            if(MessageId<0){
                //表示注册失败
                  System.out.println("消息保存失败");   //----------------------------------          
              }
              
            //表示注册成功
              System.out.println("消息保存成功"); 
		    
		}else if(temptemp.getTypeName().equals("image")){
        	//向数据库中保存消息数据
            fromId = Integer.toString(temptemp.getFromID());
            toId = Integer.toString(temptemp.getToID());
            fromName = temptemp.getFromName();
            Message messageSave = new Message();
            messageSave.setDate(new Date());
            messageSave.setTypeName(temptemp.getTypeName());
            messageSave.setFromID(temptemp.getFromID());
            messageSave.setFromName(temptemp.getFromName());
            messageSave.setToID(temptemp.getToID());
//            messageSave.setFileURL("null");
//            messageSave.setText("null");
            
            MessageId = messageService.insertMessage(messageSave);   //该消息在数据库中的id         
            if(MessageId<0){
                //表示注册失败
                  System.out.println("消息保存失败");   //----------------------------------          
              }
              
            //表示注册成功
              System.out.println("消息保存成功"); 
		    
		}else {                           //处理文本数据*********************************************************************************************************
			//反序列化服务端收到的json消息
			Message msg = GsonUtils.fromJson(message.getPayload().toString(), Message.class);			
			msg.setDate(new Date());
			MessageId = messageService.insertMessage(msg);   //该消息在数据库中的id
			
			System.out.println(msg.getTypeName()+"msg.getTypeName()");
			//处理html的字符，转义：
			String text = msg.getText();
			//转换为HTML转义字符表示
			String htmlEscapeText = HtmlUtils.htmlEscape(text);
			msg.setText(htmlEscapeText);
			System.out.println("消息（可存数据库作为历史记录）:"+message.getPayload().toString());
			if(USER_SOCKETSESSION_MAP.get(Integer.toString(msg.getFromID())) == null) {
				msg.setText("由于你的言行恶劣，已经被剔除");
				msg.setToID(msg.getFromID());
				//在重新赋值fromID,将其赋值为管理员id  这里先将管理员id写死   默认admin的id=6
				msg.setFromID(6);
			}
			//判断是群发还是单发
			//Integer.toString(msg.getToID())
			if (Integer.toString(msg.getToID())==null || Integer.toString(msg.getToID()).equals("-1")){
				System.out.println("这里实现的是消息的群发&&&&&&&&&&&&&&&&………………………………………………………………………………………………………………");
				//群发###################################################################
				sendMessageToAll(webSocketSession, new TextMessage(GsonUtils.toJson(msg)));
			}else {
				System.out.println(Integer.toString(msg.getToID())+"getFromID()这里实现的是消息的单发&&&&&&&&&&&&&&&&………………………………………………………………………………………………………………");
				//单发####################################################################
				sendMessageToUser(webSocketSession, Integer.toString(msg.getFromID()), Integer.toString(msg.getToID()), new TextMessage(GsonUtils.toJson(msg)));
			}
			
		}
				
	}
	
	//处理二进制消息*******************************************************************************************
	public void handleBinaryMessage(WebSocketSession session, WebSocketMessage<?> message, String fromId, String toId) throws IOException
    {
	    int CHUNK_SIZE = 2*1024*1024;    //最大一次传输2M
	    fileAndFalg++;  //每读取一次加1
	    WebSocketSession webSocketSessionFrom = USER_SOCKETSESSION_MAP.get(fromId);
	    Message msg = GsonUtils.fromJson(message.getPayload().toString(), Message.class);
	    String messageData = msg.getText();
        msg.setDate(new Date());
        msg.setText("false");
        int fileEndNum = msg.getId();  //文件总的分块数
 
	    //将messageData字符串转换成byte[];
        byte[] bytes = messageData.getBytes();
        output.write(bytes);
        //ByteBuffer buffer= message.getPayload();
		try {
		    System.out.println("fileAndFalg====     "+fileAndFalg+"     @@@@@@@@@@@      "+"fileEndNum====     "+fileEndNum+"      @@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		    System.out.println(message.getPayloadLength()%CHUNK_SIZE+"                message.getPayloadLength()%CHUNK_SIZE");
		    if(fileAndFalg == fileEndNum){     //给客户端一个反馈    表示文件全部接收完成
		        System.out.println("hello hello hello hello hello");
		        msg.setText("true");
		        TextMessage messageTemp = new TextMessage(GsonUtils.toJson(msg));
		        webSocketSessionFrom.sendMessage(messageTemp);
		    }else{                                            //给客户端一个反馈   表示文件未全部接收完成
		        System.out.println("hello111 hello1111 hello1111 hello111 hello111");
		        TextMessage messageTemp = new TextMessage(GsonUtils.toJson(msg));
                webSocketSessionFrom.sendMessage(messageTemp);
		    }
		    
			
		} catch (IOException e) {
			e.printStackTrace();
		}
		System.out.println("二进制文件写入完毕");
    }

	@Override   
	/**
     * 消息传输过程中出现的异常处理函数   byteLength()
     * 处理传输错误：处理由底层WebSocket消息传输过程中发生的异常
     */
	public void handleTransportError(WebSocketSession webSocketSession, Throwable exception) throws Exception {
		// 记录日志，准备关闭连接
		System.out.println("Websocket异常断开:" + webSocketSession.getId() + "已经关闭");
		User loginUser = new User();
		//获取异常的用户的会话中的用户编号
		loginUser=(User)webSocketSession.getAttributes().get("loginUser");
		//一旦发生异常，强制用户下线，关闭session
		if (webSocketSession.isOpen()) {
		    //修改用户状态
			loginUser.setState(0);
	        userService.modifyUserStateById(loginUser);
			webSocketSession.close();
		}
		
		//群发消息告知大家
		Message msg = new Message();
		msg.setDate(new Date());
		
		//获取异常的用户的会话中的用户编号
//		loginUser=(User)webSocketSession.getAttributes().get("loginUser");
		
		//获取所有的用户的会话
		Set<Entry<String, WebSocketSession>> entrySet = USER_SOCKETSESSION_MAP.entrySet();
		//并查找出在线用户的WebSocketSession（会话），将其移除（不再对其发消息了。。）
		for (Entry<String, WebSocketSession> entry : entrySet) {
			if (entry.getKey().equals(Integer.toString(loginUser.getId()))){
				msg.setText("【"+loginUser.getNickname()+"】已下线！");
				//清除在线会话
				USER_SOCKETSESSION_MAP.remove(entry.getKey());
				//记录日志：
				System.out.println("Socket会话已经移除Error:用户ID" + entry.getKey());
				break;
			}
		}
		
		//并查找出在线用户的WebSocketSession（会话），将其移除（不再对其发消息了。。）
		for (Entry<String, WebSocketSession> entry : entrySet) {
			msg.getUserList().add((User)entry.getValue().getAttributes().get("loginUser"));
		}
		
		TextMessage message = new TextMessage(GsonUtils.toJson(msg));
		sendMessageToAll(webSocketSession, message);
		
	}

	@Override
	/**
     * websocket链接关闭的回调
     * 连接关闭后：一般是回收资源等
     */
	public void afterConnectionClosed(WebSocketSession webSocketSession, CloseStatus closeStatus) throws Exception {
		// 记录日志，准备关闭连接
		System.out.println("Websocket正常断开:" + webSocketSession.getId() + "已经关闭");
		
		//群发消息告知大家
		Message msg = new Message();
		msg.setDate(new Date());
		User loginUser = new User();
		if(idsss == null) {
			//获取异常的用户的会话中的用户编号
			loginUser=(User)webSocketSession.getAttributes().get("loginUser");
			//群发消息告知大家
			msg.setText("【"+loginUser.getNickname()+"】已下线！");
		}else {
			loginUser.setId(Integer.parseInt(idsss));
			loginUser.setNickname(userNamesss);
			idsss=null;
			userNamesss=null;
		}
		Set<Entry<String, WebSocketSession>> entrySet = USER_SOCKETSESSION_MAP.entrySet();
		//并查找出在线用户的WebSocketSession（会话），将其移除（不再对其发消息了。。）
		for (Entry<String, WebSocketSession> entry : entrySet) {
			if (entry.getKey().equals(Integer.toString(loginUser.getId()))){
				//群发消息告知大家
				msg.setText("【"+loginUser.getNickname()+"】已下线！");
				//清除在线会话
				USER_SOCKETSESSION_MAP.remove(entry.getKey());
				//记录日志：
				System.out.println("Socket会话已经移除Closed:用户ID" + entry.getKey());
				break;
			}
		}
		
		//并查找出在线用户的WebSocketSession（会话），将其移除（不再对其发消息了。。）
		for (Entry<String, WebSocketSession> entry : entrySet) {
			msg.getUserList().add((User)entry.getValue().getAttributes().get("loginUser"));
		}
		
		TextMessage message = new TextMessage(GsonUtils.toJson(msg));
		sendMessageToAll(webSocketSession, message);
	}

//###################################################################################### 给单个人发消息	
	@Override
	 /**
     * 是否支持处理拆分消息，返回true返回拆分消息
     */
	//是否支持部分消息：如果设置为true，那么一个大的或未知尺寸的消息将会被分割，并会收到多次消息（会通过多次调用方法handleMessage(WebSocketSession, WebSocketMessage). ）
	//如果分为多条消息，那么可以通过一个api：org.springframework.web.socket.WebSocketMessage.isLast() 是否是某条消息的最后一部分。
	//默认一般为false，消息不分割
	public boolean supportsPartialMessages() {
		return false;
	}

	/**
	 * 
	 *  说明：给某个人发信息#############################################
	 * @param id
	 * @param message
	 * @author 传智.BoBo老师
	 * @throws IOException 
	 * @time：2016年10月27日 下午10:40:52
	 */
	
	/**
	 * 这里可以实现消息的单发******************************************可以增强的地方
	 * @param id
	 * @param message
	 * @throws IOException
	 */
	
	//文件传输------------------------------------------------------
	//文件传输------单发
	public void sendFileMessageToUser(WebSocketSession webSocketSession2, String fromId, String toId, WebSocketMessage<?> message) throws IOException {
				
				System.out.println("-1-1-1-1-1-1-1-1-1");
				//获取到要接收消息的用户的session
				WebSocketSession webSocketSession = USER_SOCKETSESSION_MAP.get(toId);    
				WebSocketSession webSocketSessionFrom = USER_SOCKETSESSION_MAP.get(fromId);
				
				//output.close();  //关闭文件传输流

				//从MessageURLURL中获取文件名
				String fileName=MessageURLURL.substring(MessageURLURL.lastIndexOf("\\")+1);
				sendPicture(webSocketSession, fileName, message);   //想目标用户发送文件
				sendPicture(webSocketSessionFrom,fileName, message);    //自己聊天窗口上文件的显示
		
	}
	
	//文件传输------群发
	public void sendFileMessageToAll(WebSocketSession webSocketSession2, WebSocketMessage<?> message) throws IOException {
		System.out.println("all all all");
				//对用户发送的消息内容进行转义				
				//获取到所有在线用户的SocketSession对象
				Set<Entry<String, WebSocketSession>> entrySet = USER_SOCKETSESSION_MAP.entrySet();
				//output.close();  //关闭文件传输流

				String fileName=MessageURLURL.substring(MessageURLURL.lastIndexOf("\\")+1);
				for (Entry<String, WebSocketSession> entry : entrySet) {
					//某用户的WebSocketSession
					final WebSocketSession webSocketSession = entry.getValue();
					//判断连接是否仍然打开的
					if (webSocketSession.isOpen()){
						//开启多线程发送消息（效率高）
						new Thread(new Runnable() {
							public void run() {
//								try {
										if (webSocketSession.isOpen()) {
											//output.close();  //关闭文件传输流											
											try {
                                                sendPicture(webSocketSession, fileName, message);
                                            } catch (IOException e) {
                                                // TODO Auto-generated catch block
                                                e.printStackTrace();
                                            }   //将文件发送给所有在线用户
										}
//									} catch (IOException e) {
//										e.printStackTrace();
//									}
								}

							}).start();
										
						}
					}
								
	}
	
	
	//文本消息发送-----------------------------------------------------------
	private void sendMessageToUser(WebSocketSession webSocketSession2, String fromId, String toId, TextMessage message) throws IOException{
				
				//获取到要接收消息的用户的session
				WebSocketSession webSocketSession = USER_SOCKETSESSION_MAP.get(toId);
				WebSocketSession webSocketSessionFrom = USER_SOCKETSESSION_MAP.get(fromId);
				if (webSocketSession != null && webSocketSession.isOpen()) {
					//发送消息
					webSocketSession.sendMessage(message);
					webSocketSessionFrom.sendMessage(message);
				}
				
	}
	
	/**
	 * 
	 * 说明：群发信息：给所有在线用户发送消息
	 * @author 传智.BoBo老师
	 * @time：2016年10月27日 下午10:40:07
	 */
	private void sendMessageToAll(WebSocketSession webSocketSession2, final TextMessage message){
		
				//对用户发送的消息内容进行转义
		
				//获取到所有在线用户的SocketSession对象
				Set<Entry<String, WebSocketSession>> entrySet = USER_SOCKETSESSION_MAP.entrySet();
				for (Entry<String, WebSocketSession> entry : entrySet) {
					//某用户的WebSocketSession
					final WebSocketSession webSocketSession = entry.getValue();
					//判断连接是否仍然打开的
					if (webSocketSession.isOpen()){
						//开启多线程发送消息（效率高）
						new Thread(new Runnable() {
							public void run() {
								try {
									if (webSocketSession.isOpen()) {
										webSocketSession.sendMessage(message);   //前端通过"event.data"接受该消息
									}
								} catch (IOException e) {
									e.printStackTrace();
								}
							}

						}).start();
						
					}
				}
				
	}
	
	//文件传输**************************************************************************************
	//使用Json数据格式
	public void sendPicture(WebSocketSession session,String fileName, WebSocketMessage<?> message) throws IOException{
		System.out.println(fileName+"fileNamefileNamefileNamefileNamefileNamefileName");
		//根据消息的id更新Message的fileURL值 
		Message messs = new Message();
		messs.setId(MessageId);
		messs.setFileURL(MessageURLURL);
        messageService.updateMessageURL(messs);
		
		//反序列化服务端收到的json消息
		Message msg = new Message();
		//设置消息发送时间
		msg.setDate(new Date());
		//判断是发送图片还是文件
		if(fileName.endsWith(".doc") || fileName.endsWith(".docx") || fileName.endsWith(".xls") || fileName.endsWith(".xlsx") || fileName.endsWith(".txt") || fileName.endsWith(".pdf") || fileName.endsWith(".caj") || fileName.endsWith(".xml") || fileName.endsWith(".zip") || fileName.endsWith(".rar") || fileName.endsWith(".mp4") || fileName.endsWith(".avi") || fileName.endsWith(".mp3")) {
			//id=0  表示发送的是文件
			//设置设发送标志
			msg.setId(0);	
		}else {
			//id=1  表示发送的是图片
			//设置设发送标志
			msg.setId(1);
		}
        //设置文件名
        msg.setTypeName(fileName);
        //设置访问文件路径
        msg.setText(fileName);
        //设置fromName
        msg.setFromName(fromName);
        TextMessage textMessage = new TextMessage(GsonUtils.toJson(msg));
        session.sendMessage(textMessage);
        
        
//		FileInputStream input;   //文件输出流
//		try {
//			File file=new File("D:\\images\\"+fileName);
//			input = new FileInputStream(file);
//	    	byte bytes[] = new byte[(int) file.length()]; 
//	    	input.read(bytes);
//	    	BinaryMessage byteMessage=new BinaryMessage(bytes);    //向前端发送二进制数据
//	    	session.sendMessage(byteMessage);
//	    	input.close();
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
	}
}                 
package com.kedacom.chartroom.web.websocket;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

/**
 * 
 * 说明：WebScoket配置处理器
 * 把处理器和拦截器注册到spring websocket中
 * <p>主题：UserService.java</p>
 * <p>内容描述：</p>
 * <p>版权：Copyright(C) 2019</p>
 * <p>公司：www.kedacom.com</p>
 * @author 沈华理
 * @date 2019年4月16日
 * 
 */
@Component("webSocketConfig")
//配置开启WebSocket服务用来接收ws请求
@EnableWebSocket     //这个注解必须要添加      为了开启Socket服务#################################
public class WebSocketConfig implements WebSocketConfigurer {

	//注入处理器
	@Autowired
	private ChatWebSocketHandler webSocketHandler;   // 该类用来处理消息###########################
	//注入拦截器对象   增强握手前或握手后的动作
	@Autowired
	private ChatHandshakeInterceptor chatHandshakeInterceptor;
	
	//注册具体的服务****************************************************
	public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
		//添加一个处理器还有定义处理器的处理路径
		/*
		 * addHandler(webSocketHandler, "/ws"):参数1：为WebSocket处理器(用来处理聊天的内容)；
		 *                                     参数2：WebSocket的访问地址，就是定义jsp页面中的访问地址："ws://" + path + "ws"
		 */
		//chatHandshakeInterceptor：自定义一个过滤器
		//.addInterceptors(...): 为了进行功能增强    增强器
		//setAllowedOrigins():  允许指定的域名或IP(含端口号)建立长链接，默认不写的话只有本地可以访问。如果不限时使用"*"号，如果指定了域名，则必须以http或https开头
//		registry.addHandler(webSocketHandler, "/ws").setAllowedOrigins("*").addInterceptors(chatHandshakeInterceptor);
		registry.addHandler(webSocketHandler, "/ws").addInterceptors(chatHandshakeInterceptor);
		/*
		 * 在这里我们用到.withSockJS()，SockJS是spring用来处理浏览器对websocket的兼容性，
		 * 目前浏览器支持websocket还不是很好，特别是IE11以下.
		 * SockJS能根据浏览器能否支持websocket来提供三种方式用于websocket请求，
		 * 三种方式分别是 WebSocket, HTTP Streaming以及 HTTP Long Polling
		 */
		registry.addHandler(webSocketHandler, "/ws/sockjs").addInterceptors(chatHandshakeInterceptor).withSockJS();
	}
	

}
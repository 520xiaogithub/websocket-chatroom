package com.kedacom.chartroom.web.websocket;

import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import com.kedacom.chartroom.domain.User;

/**
 * websocket的链接建立是基于http握手协议，我们可以添加一个拦截器处理握手之前和握手之后过程
 * <p>主题：UserService.java</p>
 * <p>内容描述：</p>
 * <p>版权：Copyright(C) 2019</p>
 * <p>公司：www.kedacom.com</p>
 * @author 沈华理
 * @date 2019年4月16日
 *
 */
@Component
public class ChatHandshakeInterceptor implements HandshakeInterceptor{

	/**
     * 握手之前，若返回false，则不建立链接
     */
    
    //WebSocket自己本身也有session对象
	@Override
	public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler,
			Map<String, Object> attributes) throws Exception {
		if (request instanceof ServletServerHttpRequest) {
			ServletServerHttpRequest servletRequest = (ServletServerHttpRequest) request;
			HttpSession session = servletRequest.getServletRequest().getSession(false);
			//如果用户已经登录，允许聊天
			if(session.getAttribute("loginUser")!=null){
				//获取登录的用户
				User loginUser=(User)session.getAttribute("loginUser") ;
				//将用户放入socket处理器的会话(WebSocketSession)中
				attributes.put("loginUser", loginUser);
				System.out.println("Websocket:用户[ID:" + (loginUser.getId() + ",Name:"+loginUser.getNickname()+"]要建立连接"));
			}else{
				//用户没有登录，拒绝聊天
				//握手失败！
				System.out.println("--------------握手已失败...");
				return false;
			}
		}
		System.out.println("--------------握手开始...");
		return true;
	}

	/**
     * 握手之后
     */
	@Override
	public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler,
			Exception exception) {
		System.out.println("--------------握手成功啦...");
	}

}

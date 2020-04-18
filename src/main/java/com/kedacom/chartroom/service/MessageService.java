package com.kedacom.chartroom.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.kedacom.chartroom.domain.Message;
import com.kedacom.chartroom.mapper.MessageMapper;

@Service
public class MessageService {
	
	@Autowired
	private MessageMapper messageMapper;
	
	//保存消息
	public int insertMessage(Message message) {
		messageMapper.insert(message);
		System.out.println(message.getId());   //回显id
		return message.getId();
	}
	
	//根据消息id更新消息fileURL值
	public void updateMessageURL(Message message) {
		messageMapper.updateURL(message);
	}
}

package com.kedacom.chartroom.mapper;

import com.kedacom.chartroom.domain.Message;

public interface MessageMapper {
	
	public int insert(Message message);
	
	public void updateURL(Message message);
}

package com.kedacom.chartroom.domain;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.google.gson.annotations.Expose;

/**
 * DTO类，用来存放聊天的消息
 * 
 *
 */
public class Message {

	@Expose
	// 消息ID----主键 自增
	private Integer id;
	@Expose // 没有@Expose注释的属性将不会被序列化
	// 消息类型
	public String typeName;
	// ###########################################
	// 发送者 指向用户表中的ID ----外键
	@Expose
	public Integer fromID; // 发送者的ID from
	// 发送者名称--------------外键
	@Expose
	public String fromName;
	// 接收者 指向用户表中的ID ----外键
	@Expose
	public Integer toID; // 接受者的ID
	// 发送的消息内容
	@Expose
	public String text;
	// 发送日期
	@Expose
	public Date date;
	// 用户上传的文件路径
	@Expose
	public String fileURL;
	// 在线用户列表
	@Expose
	List<User> userList = new ArrayList<>();

	public final Integer getId() {
		return id;
	}

	public final void setId(Integer id) {
		this.id = id;
	}

	public final String getTypeName() {
		return typeName;
	}

	public final void setTypeName(String typeName) {
		this.typeName = typeName;
	}

	public final Integer getFromID() {
		return fromID;
	}

	public final void setFromID(Integer fromID) {
		this.fromID = fromID;
	}

	public final String getFromName() {
		return fromName;
	}

	public final void setFromName(String fromName) {
		this.fromName = fromName;
	}

	public final Integer getToID() {
		return toID;
	}

	public final void setToID(Integer toID) {
		this.toID = toID;
	}

	public final String getText() {
		return text;
	}

	public final void setText(String text) {
		this.text = text;
	}

	public final Date getDate() {
		return date;
	}

	public final void setDate(Date date) {
		this.date = date;
	}

	public final List<User> getUserList() {
		return userList;
	}

	public final void setUserList(List<User> userList) {
		this.userList = userList;
	}

	public String getFileURL() {
		return fileURL;
	}

	public void setFileURL(String fileURL) {
		this.fileURL = fileURL;
	}

	@Override
	public String toString() {
		return "Message [id=" + id + ", typeName=" + typeName + ", fromID=" + fromID + ", fromName=" + fromName + ", toID=" + toID + ", text=" + text + ", date=" + date + ", fileURL=" + fileURL + ", userList=" + userList + "]";
	}

}
package com.kedacom.chartroom.domain;

import com.google.gson.annotations.Expose;

//用户
public class User {
	@Expose
	private Integer id;// 唯一标识属性
	@Expose
	private String nickname;
	private String password;
	private Integer state; // 1:表示在线 ；0:表示下线    用户注册时默认赋值为0 ； 用户登录时默认值修改为1；用户退出时，默认值修改为0
	private Integer sign;

	//也可以使用flexjson工具包，进行Json格式的转换         使用该工具包可以在对应的getXxx()方法上加@Json(include=false)：排除该属性转换为Json
	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		
		this.password = password;
	}

	public String getNickname() {
		return nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public final Integer getId() {
        return id;
    }

    public final void setId(Integer id) {
        this.id = id;
    }

    public Integer getState() {
		return state;
	}

	public void setState(Integer state) {
		this.state = state;
	}

    public Integer getSign() {
		return sign;
	}

	public void setSign(Integer sign) {
		this.sign = sign;
	}

    @Override
	public String toString() {
		return "User [id=" + id + ", nickname=" + nickname + ", password=" + password + ", state=" + state + ", sign=" + sign + "]";
	}

    /**
     * 
     */
    public User() {
    	super();
    }

	public User(Integer id, String nickname, String password, Integer state, Integer sign) {
		super();
		this.id = id;
		this.nickname = nickname;
		this.password = password;
		this.state = state;
		this.sign = sign;
	}    
	
}

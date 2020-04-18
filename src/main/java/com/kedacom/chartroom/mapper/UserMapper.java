package com.kedacom.chartroom.mapper;

import java.util.List;

import com.kedacom.chartroom.domain.User;


/**
 * <p>主题：UserMapper.java</p>
 * <p>内容描述：</p>
 * <p>版权：Copyright(C) 2019</p>
 * <p>公司：www.kedacom.com</p>
 * @author 沈华理
 * @date 2019年4月16日
 */

public interface UserMapper {
    
    //根据用户名进行查询
//    @Select("SELECT * FROM USER WHERE NAME= #{nickname}")
    public User findByName(String nickname);
    
    //用户注册
//    @Insert("INSERT INTO USER(ID, NICKNAME,PASSWORD,STATE) VALUES(#{nickname} ,#{password} ,#{state})")
    public int insert(User user);
    
    //用户登录
    public Object login(User user);
    
    //更新用户状态
    public void modifyStateById(User user);
    
    //获取所有在线登录用户
    public List<User> findAllOnlineUser(User user);

    //删除用户
	public void deleteUserById(Integer id);
}





package com.kedacom.chartroom.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import utils.MD5Utils;

import com.kedacom.chartroom.domain.User;
import com.kedacom.chartroom.mapper.UserMapper;

/**
 * <p>主题：UserService.java</p>
 * <p>内容描述：</p>
 * <p>版权：Copyright(C) 2019</p>
 * <p>公司：www.kedacom.com</p>
 * @author 沈华理
 * @date 2019年4月16日
 */

@Service
public class UserService {
    
    @Autowired
    public UserMapper userMapper;
    
    //根据用户名进行查询
    public User findByUserName(String nickname){
    	if(nickname==null) {
    		return null;
    	}
    	return userMapper.findByName(nickname);
    } 
    
    //用户添加
    public int insertUser(User user){
        //使用日志记录信息
        //使用MD5进行数据加密
        String passwordMD5 = MD5Utils.md5(user.getPassword());
        System.out.println(passwordMD5+"...................................");
        user.setPassword(passwordMD5);
        userMapper.insert(user);
        System.out.println("############"+user.getNickname());
        System.out.println(user.getId());
        return user.getId();
    }
    
    //进行用户登录验证并返回用户id
    public Object login(User user){
        
        String passwordMD5 = MD5Utils.md5(user.getPassword());
        user.setPassword(passwordMD5);
        Object id=userMapper.login(user);
        if(id==null){
            return -1;
        }
        System.out.println(id+"#####################################");
        return id;
    }
    
    //更新用户状态
    public void modifyUserStateById(User user){
        userMapper.modifyStateById(user);
    }
    
    //获取所有在线登录用户
    public List<User> getAllOnlineUser(User user){
        
        return userMapper.findAllOnlineUser(user);
    }

	public void deleteSelectOnlineUser(String ids) {
		//分割字符串
		String[] idArray = ids.split(",");
		//删除用户
		for (String id : idArray) {
			//调用dao层
			userMapper.deleteUserById(Integer.parseInt(id));
		}
	}
}
















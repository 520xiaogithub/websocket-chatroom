package com.kedacom.chartroom.web.controller;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.Random;

import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/*
 * 生成验证码
 * <p>主题：UserService.java</p>
 * <p>内容描述：</p>
 * <p>版权：Copyright(C) 2019</p>
 * <p>公司：www.kedacom.com</p>
 * @author 沈华理
 * @date 2019年4月16日
 */
public class CheckImgServlet extends HttpServlet {

	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		int width = 120;
		int height = 40;
		// 相当于一张画质 内存创建一个图片缓冲区
		BufferedImage bufi = new BufferedImage(width, height,
				BufferedImage.TYPE_INT_RGB);

		// 给图片缓冲区中写数据
		// 画笔
		Graphics g = bufi.getGraphics();

		// 设置画笔的颜色
		g.setColor(Color.WHITE);
		// 修改图片的背景颜色
		g.fillRect(0, 0, width, height);

		g.setColor(Color.RED);
		// 画边框
		g.drawRect(0, 0, width - 1, height - 1);

		String data = "QWERTYUPASDFGHJKLZXCVBNMqwertyupasdfghjkzxcvbnm0123456789";
		int x = 10;
		int y = 30;
		// 定义一个随机数对象
		Random r = new Random();
		
		//定义一个StringBuilder ，用户保存给图片上写的数据
		StringBuilder sb = new StringBuilder();
		// 生成干扰线
		for (int i = 0; i < 8; i++) {
			g.setColor(new Color(r.nextInt(255), r.nextInt(255), r.nextInt(255)));
			g.drawLine(r.nextInt(width), r.nextInt(height), r.nextInt(width),
					r.nextInt(height));
		}
		for (int i = 0; i < 4; i++) {

			// 设置画笔的颜色，让不同的字显示不同的颜色
			g.setColor(new Color(r.nextInt(255), r.nextInt(255), r.nextInt(255)));
			// 设置字体大小
			g.setFont(new Font("宋体", Font.ITALIC, 25));

			int num = r.nextInt(data.length());
			char ch = data.charAt(num);
			sb.append(ch);
			g.drawString( ch+ "", x, y);
			x += 20;
		}
		//获取Session,把验证码图片上的数据保存在Session中
		System.out.println(sb.toString()+"$$$$$$$$$$$$$$$>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		request.getSession().setAttribute("servletImg", sb.toString());
		
		// 把图片缓冲区中的数据写到页面
		ImageIO.write(bufi, "JPG", response.getOutputStream());
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

}

package utils;

import java.lang.reflect.Type;

import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

//gson的工具类
public class GsonUtils {
	//线程安全的
	private static final Gson GSON;
	static{
		GSON = new GsonBuilder()     
				.excludeFieldsWithoutExposeAnnotation()//打开Export注解，但打开了这个注解,副作用，要转换和不转换都要加注解
//	            .serializeNulls()  //是否序列化空值 
	            .setDateFormat("yyyy-MM-dd HH:mm:ss")//序列化日期格式  "yyyy-MM-dd"
//	            .setFieldNamingPolicy(FieldNamingPolicy.UPPER_CAMEL_CASE)//会把字段首字母大写
	            .setPrettyPrinting() //自动格式化换行
//	            .setVersion(2.0)  //需要结合注解使用，有的字段在1。0的版本的时候解析，但0。1版本不解析
	            .create();
	}
	
	//获取gson解析器
	public static Gson getGson(){
		return GSON;
	}
	
	//对象转换为json
	public static String toJson(Object object){
		return GSON.toJson(object);
	}
	
	//反序列化
	//JSON转换为对象1--普通类型
	public static <T> T fromJson(String json, Class<T> classOfT){
		return GSON.fromJson(json, classOfT);
	}
	//JSON转换为对象-针对泛型的类型
	public static <T> T fromJson(String json, Type typeOfT){
		return GSON.fromJson(json, typeOfT);
	}
	

}

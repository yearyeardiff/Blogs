---
title: JVM---类加载过程
tags: jvm,类加载器,类加载过程
grammar_cjkRuby: true
---

* [类加载过程](#类加载过程)
	* [加载](#加载)
	* [验证](#验证)
	* [准备](#准备)
	* [解析](#解析)
	* [初始化](#初始化)
* [类加载器](#类加载器)
	* [类与类加载器](#类与类加载器)
	* [双亲委派模型](#双亲委派模型)
	* [自定义类加载器](#自定义类加载器)
	* [ClassLoader 隔离问题](#classloader-隔离问题)

# 类加载过程
使用java编译器可以把java代码编译为存储字节码的Class文件，使用其他语言的编译器一样可以把程序代码翻译成Class文件，java虚拟机不关心Class的来源是何种语言。如图所示：

![enter description here][1]

那么虚拟机是如何加载这些Class文件的呢？
JVM把描述类数据的字节码.Class文件加载到内存，并对数据进行校验、转换解析和初始化，最终形成可以被虚拟机直接使用的java类型，这就是虚拟机的类加载机制。
 
类从被加载到虚拟机内存中开始，到卸载出内存为止，它的生命周期包括了：加载(Loading)、验证(Verification)、准备(Preparation)、解析(Resolution)、初始化(Initialization)、使用(Using)、卸载(Unloading)七个阶段，其中验证、准备、解析三个部分统称链接。

![enter description here][2]

## 加载
加载阶段是“类加载机制”中的一个阶段，这个阶段通常也被称作“装载”，主要完成：

 1. 通过“类全名”来获取定义此类的二进制字节流
 2. 将字节流所代表的静态存储结构转换为方法区的运行时数据结构
 3. 在java堆中生成一个代表这个类的java.lang.Class对象，作为方法区这些数据的访问入口

## 验证
验证是链接阶段的第一步，这一步主要的目的是确保class文件的字节流中包含的信息符合当前虚拟机的要求，并且不会危害虚拟机自身安全。
验证阶段主要包括四个检验过程：文件格式验证、元数据验证、字节码验证和符号引用验证。

 1. 文件格式验证

 验证class文件格式规范，例如： class文件是否已魔术0xCAFEBABE开头 ， 主、次版本号是否在当前虚拟机处理范围之内等

 2. 元数据验证

这个阶段是对字节码描述的信息进行语义分析，以保证起描述的信息符合java语言规范要求。验证点可能包括：这个类是否有父类(除了java.lang.Object之外，所有的类都应当有父类)、这个类是否继承了不允许被继承的类(被final修饰的)、如果这个类的父类是抽象类，是否实现了起父类或接口中要求实现的所有方法。

 3. 字节码验证

进行数据流和控制流分析，这个阶段对类的方法体进行校验分析，这个阶段的任务是保证被校验类的方法在运行时不会做出危害虚拟机安全的行为。如：保证访法体中的类型转换有效，例如可以把一个子类对象赋值给父类数据类型，这是安全的，但不能把一个父类对象赋值给子类数据类型、保证跳转命令不会跳转到方法体以外的字节码命令上。

 4. 符号引用验证

符号引用中通过字符串描述的全限定名是否能找到对应的类、符号引用类中的类，字段和方法的访问性(private、protected、public、default)是否可被当前类访问。
## 准备


准备阶段是正式为**类变量**分配内存并设置类变量初始值的阶段，这些内存都将在方法区中进行分配。
首先是这时候进行内存分配的仅包括类变量(static 修饰的变量),而不包括实例变量，实例变量将会在对象实例化时随着对象一起分配在java堆中。这里所说的初始值“通常情况”下是数据类型的零值，假设一个类变量定义为:

``` java
public static int value  = 12;//(非final)
```


那么变量value在准备阶段过后的初始值为0而不是12，因为这时候尚未开始执行任何java方法，而把value赋值为123的putstatic指令是程序被编译后，存放于类构造器\<clinit\>()方法之中，所以把value赋值为12的动作将在初始化阶段才会被执行。
上面所说的“通常情况”下初始值是零值，那相对于一些特殊的情况，如果类字段的字段属性表中存在ConstantValue属性，那在准备阶段变量value就会被初始化为ConstantValue属性所指定的值，建设上面类变量value定义为：

``` java
public static final int value = 123;//(final)
```
编译时javac将会为value生成ConstantValue属性，在准备阶段虚拟机就会根据ConstantValue的设置将value设置为123。



## 解析
解析主要就是将常量池中的符号引用替换为直接引用的过程。符号引用就是一组符号来描述目标，可以是任何字面量，而直接引用就是直接指向目标的指针、相对偏移量或一个间接定位到目标的句柄。有类或接口的解析，字段解析，类方法解析，接口方法解析。
## 初始化
类的初始化阶段是类加载过程的最后一步，在准备阶段，类变量已赋过一次系统要求的初始值，而在初始化阶段，则是根据程序员通过程序制定的主观计划去初始化类变量和其他资源，或者可以从另外一个角度来表达：初始化阶段是执行类构造器\<clinit>()方法的过程。在以下四种情况下初始化过程会被触发执行：

 1. 遇到new、getstatic、putstatic或invokestatic这4条字节码指令时，如果类没有进行过初始化，则需先触发其初始化。生成这4条指令的最常见的java代码场景是：使用new关键字实例化对象、读取或设置一个类的静态字段(被final修饰、已在编译器把结果放入常量池的静态字段除外)的时候，以及调用类的静态方法的时候。
 2. 使用java.lang.reflect包的方法对类进行反射调用的时候
 3. 当初始化一个类的时候，如果发现其父类还没有进行过初始化、则需要先出发其父类的初始化
 4. jvm启动时，用户指定一个执行的主类(包含main方法的那个类)，虚拟机会先初始化这个类

在上面准备阶段 public static int value  = 12;  在准备阶段完成后 value的值为0，而在初始化阶调用了类构造器\<clinit\>()方法，这个阶段完成后value的值为12。

 - 类构造器\<clinit\>()方法是由编译器自动收集类中的所有类变量的赋值动作和静态语句块(static块)中的语句合并产生的，编译器收集的顺序是由语句在源文件中出现的顺序所决定的，静态语句块中只能访问到定义在静态语句块之前的变量，定义在它之后的变量，在前面的静态语句快可以赋值，但是不能访问。
 - 类构造器\<clinit>()方法与类的构造函数(实例构造函数\<init>()方法)不同，它不需要显式调用父类构造，虚拟机会保证在子类\<clinit>()方法执行之前，父类的\<clinit>()方法已经执行完毕。因此在虚拟机中的第一个执行的\<clinit>()方法的类肯定是java.lang.Object。
 - 由于父类的\<clinit>()方法先执行，也就意味着父类中定义的静态语句快要优先于子类的变量赋值操作。
 - \<clinit>()方法对于类或接口来说并不是必须的，如果一个类中没有静态语句，也没有变量赋值的操作，那么编译器可以不为这个类生成\<clinit>()方法。
 - 接口中不能使用静态语句块，但接口与类不太能够的是，执行接口的\<clinit>()方法不需要先执行父接口的\<clinit>()方法。只有当父接口中定义的变量被使用时，父接口才会被初始化。另外，接口的实现类在初始化时也一样不会执行接口的\<clinit>()方法。
 - 虚拟机会保证一个类的\<clinit>()方法在多线程环境中被正确加锁和同步，如果多个线程同时去初始化一个类，那么只会有一个线程执行这个类的\<clinit>()方法，其他线程都需要阻塞等待，直到活动线程执行\<clinit>()方法完毕。如果一个类的\<clinit>()方法中有耗时很长的操作，那就可能造成多个进程阻塞。

# 类加载器

> JVM设计者把类加载阶段中的“**通过'类全名'来获取定义此类的二进制字节流**”这个动作放到Java虚拟机外部去实现，以便让应用程序自己决定如何去获取所需要的类。实现这个动作的代码模块称为“类加载器”。

## 类与类加载器
对于任何一个类，都需要由加载它的类加载器和这个类来确立其在JVM中的唯一性。也就是说，两个类来源于同一个Class文件，并且被同一个类加载器加载，这两个类才相等。
## 双亲委派模型

> 从虚拟机的角度来说，只存在两种不同的类加载器：一种是启动类加载器（Bootstrap ClassLoader），该类加载器使用C++语言实现，属于虚拟机自身的一部分。另外一种就是所有其它的类加载器，这些类加载器是由Java语言实现，独立于JVM外部，并且全部继承自抽象类java.lang.ClassLoader。

从Java开发人员的角度来看，大部分Java程序一般会使用到以下三种系统提供的类加载器：

 1. 启动类加载器（Bootstrap ClassLoader）：负责加载JAVA_HOME\lib目录中并且能被虚拟机识别的类库到JVM内存中，如果名称不符合的类库即使放在lib目录中也不会被加载。该类加载器无法被Java程序直接引用。
 2. 扩展类加载器（Extension ClassLoader）：该加载器主要是负责加载JAVA_HOME\lib\ext，该加载器可以被开发者直接使用。
 3. 应用程序类加载器（Application ClassLoader）：该类加载器也称为系统类加载器，它负责加载用户类路径（Classpath）上所指定的类库，开发者可以直接使用该类加载器，如果应用程序中没有自定义过自己的类加载器，一般情况下这个就是程序中默认的类加载器。
 这些类加载器之间的关系如下图所示：
 
 ![enter description here][3]

如上图所示的类加载器之间的这种层次关系，就称为类加载器的双亲委派模型（Parent Delegation Model）。该模型要求除了顶层的启动类加载器外，其余的类加载器都应当有自己的父类加载器。子类加载器和父类加载器不是以继承（Inheritance）的关系来实现，而是通过组合（Composition）关系来复用父加载器的代码。

> 双亲委派模型的工作过程为：**如果一个类加载器收到了类加载的请求，它首先不会自己去尝试加载这个类，而是把这个请求委派给父类加载器去完成，每一个层次的加载器都是如此，因此所有的类加载请求都会传给顶层的启动类加载器，只有当父加载器反馈自己无法完成该加载请求（该加载器的搜索范围中没有找到对应的类）时，子加载器才会尝试自己去加载。**

使用这种模型来组织类加载器之间的关系的**好处**是Java类随着它的类加载器一起具备了一种带有优先级的层次关系。例如java.lang.Object类，无论哪个类加载器去加载该类，最终都是由启动类加载器进行加载，因此Object类在程序的各种类加载器环境中都是同一个类。否则的话，如果不使用该模型的话，如果用户自定义一个java.lang.Object类且存放在classpath中，那么系统中将会出现多个Object类，应用程序也会变得很混乱。如果我们自定义一个rt.jar中已有类的同名Java类，会发现JVM可以正常编译，但该类永远无法被加载运行。

实现双亲委派的代码都集中在java.lang.ClassLoader的loadClass()方法中，如下：

``` java
protected synchronized Class loadClass(String name, boolean resolve)   throws ClassNotFoundException {  
    // 首先检查该name指定的class是否有被加载  
    Class c = findLoadedClass(name);  
    if (c == null) {  
        try {  
            if (parent != null) {  
                // 如果parent不为null，则调用parent的loadClass进行加载  
                c = parent.loadClass(name, false);  
            } else {  
                // parent为null，则调用BootstrapClassLoader进行加载  
                c = findBootstrapClass0(name);  
            }  
        } catch (ClassNotFoundException e) {  
            // 如果仍然无法加载成功，则调用自身的findClass进行加载  
            c = findClass(name);  
        }  
    }  
    if (resolve) {  
        resolveClass(c);  
    }  
    return c;  
}  
```
## 自定义类加载器
java.lang.ClassLoader 类的基本职责就是**根据一个指定的类的名称，找到或者生成其对应的字节代码，然后从这些字节代码中定义出一个 Java 类**，即 java.lang.Class 类的一个实例。除此之外，ClassLoader 还负责加载 Java 应用所需的资源，如图像文件和配置文件等，ClassLoader 中与加载类相关的方法如下：

|  方法名   |   说明  |
| --- | --- |
|   getParent()  |  返回该类加载器的父类加载器   |
|  loadClass(String name)   |  加载名称为 二进制名称为name 的类，返回的结果是 java.lang.Class 类的实例   |
|  findClass(String name)    |   查找名称为 name 的类，返回的结果是 java.lang.Class 类的实例  |
|  findLoadedClass(String name)   |  查找名称为 name 的已经被加载过的类，返回的结果是 java.lang.Class 类的实例   |
| resolveClass(Class<?> c)    |   链接指定的 Java 类。  |
|  defineClass(byte[] , int ,int)    |  将byte字节流解析为JVM能够识别的Class对象（直接调用这个方法生成的Class对象还没有resolve，这个resolve将会在这个对象真正实例化时resolve）   |

 在JDK1.2之前，类加载尚未引入双亲委派模式，因此实现自定义类加载器时常常重写loadClass方法，提供双亲委派逻辑，从JDK1.2之后，双亲委派模式已经被引入到类加载体系中，自定义类加载器时不需要在自己写双亲委派的逻辑，因此不鼓励重写loadClass方法，而**推荐重写findClass方法**。
 
 

``` java
/**
	 * 一、ClassLoader加载类的顺序
	 *  1.调用 findLoadedClass(String) 来检查是否已经加载类。
	 *  2.在父类加载器上调用 loadClass 方法。如果父类加载器为 null，则使用虚拟机的内置类加载器。
	 *  3.调用 findClass(String) 方法查找类。
	 * 二、实现自己的类加载器
	 *  1.获取类的class文件的字节数组
	 *  2.将字节数组转换为Class类的实例
	 * @author lei 2011-9-1
	 */
	public class ClassLoaderTest {
	    public static void main(String[] args) throws InstantiationException, IllegalAccessException, ClassNotFoundException {
	        //新建一个类加载器
	        MyClassLoader cl = new MyClassLoader("myClassLoader");
	        //加载类，得到Class对象
	        Class<?> clazz = cl.loadClass("classloader.Animal");
	        //得到类的实例
	        Animal animal=(Animal) clazz.newInstance();
	        animal.say();
	    }
	}
	class Animal{
	    public void say(){
	        System.out.println("hello world!");
	    }
	}
	class MyClassLoader extends ClassLoader {
	    //类加载器的名称
	    private String name;
	    //类存放的路径
	    private String path = "E:\\workspace\\Algorithm\\src";
	    MyClassLoader(String name) {
	        this.name = name;
	    }
	    MyClassLoader(ClassLoader parent, String name) {
	        super(parent);
	        this.name = name;
	    }
	    /**
	     * 重写findClass方法
	     */
	    @Override
	    public Class<?> findClass(String name) {
	        byte[] data = loadClassData(name);
	        return this.defineClass(name, data, 0, data.length);
	    }
	    public byte[] loadClassData(String name) {
	        try {
	            name = name.replace(".", "//");
	            FileInputStream is = new FileInputStream(new File(path + name + ".class"));
	            ByteArrayOutputStream baos = new ByteArrayOutputStream();
	            int b = 0;
	            while ((b = is.read()) != -1) {
	                baos.write(b);
	            }
	            return baos.toByteArray();
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	        return null;
	    }
	}
```
## ClassLoader 隔离问题
大家觉得一个运行程序中有没有可能同时存在两个包名和类名完全一致的类？
JVM 及 Dalvik 对类唯一的识别是 ClassLoader id + PackageName + ClassName，所以一个运行程序中是有可能存在两个包名和类名完全一致的类的。并且如果这两个”类”不是由一个 ClassLoader 加载，是无法将一个类的示例强转为另外一个类的，这就是 ClassLoader 隔离。
当碰到这种问题时可以通过 instance.getClass().getClassLoader(); 得到 ClassLoader，看 ClassLoader 是否一样。

[参考博客：JVM（三）：类加载机制（类加载过程和类加载器）][4]


  [1]: ./images/jvm-java%E6%96%87%E4%BB%B6%E5%8A%A0%E8%BD%BD.png "jvm-java文件加载"
  [2]: ./images/jvm-%E7%B1%BB%E7%9A%84%E5%8A%A0%E8%BD%BD%E8%BF%87%E7%A8%8B.png "jvm-类的加载过程"
  [3]: ./images/jvm-%E7%B1%BB%E5%8A%A0%E8%BD%BD%E5%99%A8.png "jvm-类加载器"
  [4]: http://blog.csdn.net/boyupeng/article/details/47951037
//
//  GLView.m
//  OpenGL
//
//  Created by jyd on 2019/3/15.
//  Copyright © 2019年 jyd. All rights reserved.
//

#import "GLView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES3/gl.h>

typedef struct {
    float position[4];
    float color[4];
} CustomVertex;

static const CustomVertex vertexs[] = {
    {.position = {-1.0, 1.0, 0, 1}, .color = {1, 0, 0, 1}},
     {.position = {-1.0, -1.0, 0, 1}, .color = {0, 1, 0, 1}},
     {.position = {1.0, -1.0, 0, 1}, .color = {0, 0, 1, 1}}
};


typedef enum : NSUInteger {
    AttributePosition = 0,
    AttributeColor,
    AttributeNormal
} Attribute;


@interface GLView ()
{
    CAEAGLLayer *eaglLayer;
    EAGLContext *context;
    GLuint framebuffer;
    GLuint renderbuffer;
    
    GLint glViewAttributes[AttributeNormal];

}

@end

@implementation GLView




- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    [self render];
}


- (void)setup {
    [self setupLayer];
    [self setupContext];
    [self setupRenderbuffer];
    [self setupFramebuffer];
    [self setupVBO];
    [self complieShaders];
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (void)setupLayer {
    eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
}


- (void)setupContext {
    if (context == nil) {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    }
    NSAssert(context && [EAGLContext setCurrentContext:context], @"初始化context 失败");
}


- (void)setupRenderbuffer {
    
    //释放旧的renderbuffer
    if (renderbuffer) {
        glDeleteRenderbuffers(1, &renderbuffer);
        renderbuffer = 0;
    }
    
    //生成renderbuffer
    glGenRenderbuffers(1, &renderbuffer);
    //绑定renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    //管理renderbuffer
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
}


- (void)setupFramebuffer {
    if (framebuffer) {
        glDeleteFramebuffers(1, &framebuffer);
        framebuffer = 0;
    }
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
    
    [self checkFramebuffer];
}


- (BOOL)checkFramebuffer {
    //检查framebuffer是否创建成功
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSString *errorStr = nil;
    BOOL result = NO;
    switch (status) {
        case GL_FRAMEBUFFER_UNSUPPORTED:
            errorStr = @"不支持该格式";
            result = NO;
            break;
        case GL_FRAMEBUFFER_COMPLETE:
            errorStr = @"创建成功";
            result = YES;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            errorStr = @"缺失组件";
            result = NO;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
            errorStr = @"附加图片需指定大小";
            result = NO;
            break;
        default:
            errorStr = @"未知错误，一般情况指超出gl纹理的最大限制";
            result = NO;
            break;
    }
    
    NSLog(@"%@",errorStr);
    
    return result;
}

- (void)render {
    //清屏
//    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
//    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
//    glClearColor(0, 0.9, 1, 1);
//    glClear(GL_COLOR_BUFFER_BIT);
    
    
    ////渲染图像
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    /*解析顶点数据
      glVertexAttribPointer(<#GLuint indx#>, <#GLint size#>, <#GLenum type#>, <#GLboolean normalized#>, <#GLsizei stride#>, <#const GLvoid *ptr#>)
     index: 配置的顶点属性
     size: 顶点属性的大小 position：(xyzw)   color:（rgba)
     type: 属性类型  都是浮点型
     normalized: 是否希望数据被标准化 GL_TURE 所有数据都会映射到0到1
     stride: 顶点数据的间隔
     ptr： 数据的偏移量 如图ptr.png
     */
   
    glVertexAttribPointer(glViewAttributes[AttributePosition], 4, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), 0);
     glVertexAttribPointer(glViewAttributes[AttributeColor], 4, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), (GLvoid *)(sizeof(float) * 4));
    /*
    glDrawArrays(<#GLenum mode#>, <#GLint first#>, <#GLsizei count#>)
     mode: 绘制的类型 点 线  三角形
     first: 顶点数据的起始索引
     count: 顶点的个数
    */
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    //所有绘制准备完成， 显现到屏幕上
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

/** 顶点缓存对象 */
- (void)setupVBO {
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_STATIC_DRAW);
}

/** 着色器程序 */
- (void)complieShaders {
    //顶点着色器
    GLuint vertexShader = [self complieShader:@"OpenGL.vsh" type:GL_VERTEX_SHADER];
    //片段着色器
    GLuint fragmentShader = [self complieShader:@"OpenGL.fsh" type:GL_FRAGMENT_SHADER];
    
    //程序添加着色器
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *msgStr = [NSString stringWithUTF8String:messages];
        NSLog(@"program: %@", msgStr);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    //获取着色器脚本的变量
    glViewAttributes[AttributePosition] = glGetAttribLocation(programHandle, "position");
    glViewAttributes[AttributeColor] = glGetAttribLocation(programHandle, "color");
    
    //启用顶点绑定的脚本着色器
    glEnableVertexAttribArray(glViewAttributes[AttributePosition]);
    glEnableVertexAttribArray(glViewAttributes[AttributeColor]);
    
}


/** 获取着色器 */
- (GLuint)complieShader:(NSString *)shaderName type:(GLenum)shadertype {
    NSString *path = [[NSBundle mainBundle] pathForResource:shaderName ofType:nil];
    NSString *shaderStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (shaderStr == nil) {
        exit(1);
    }
    
    const char *shaderStrUTF8 = [shaderStr UTF8String];
    int shaderStrLength = (int)shaderStr.length;
    GLuint shaderHandle = glCreateShader(shadertype);
    
    glShaderSource(shaderHandle, 1, &shaderStrUTF8, &shaderStrLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[265];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSLog(@"shader false: %@",[NSString stringWithUTF8String:messages]);
        exit(1);
    }
    return shaderHandle;
}

@end

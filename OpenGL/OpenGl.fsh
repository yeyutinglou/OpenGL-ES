//片段着色器
varying lowp vec4 colorVarying;

void main(void) {
    gl_FragColor = colorVarying;
}

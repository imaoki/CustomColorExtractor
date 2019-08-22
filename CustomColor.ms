/*! © 2019 imaoki | MIT License | https://github.com/imaoki */
/**
カラー情報を格納する。
*/
struct CustomColorStruct (
  /** @prop <String> */
  public CategoryName = "",
  /** @prop <String> */
  public ColorName = "",
  /** @prop <Color|UndefinedClass> */
  public DisabledColor,
  /** @prop <Color|UndefinedClass> */
  public HoverColor,
  /** @prop <Color|UndefinedClass> */
  public ValueColor,

  /**
  現在の内部状態を出力する。
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @return <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%CustomColorStruct\n" indent to:out
    format "%  CategoryName: \"%\"\n" indent this.CategoryName to:out
    format "%  ColorName: \"%\"\n" indent this.ColorName to:out
    format "%  DisabledColor: %\n" indent this.DisabledColor to:out
    format "%  HoverColor: %\n" indent this.HoverColor to:out
    format "%  ValueColor: %\n" indent this.ValueColor to:out
    ok
  ),

  /**
  @param obj <Any>
  @return <BooleanClass>
  @remark 大文字と小文字を区別しない。
  */
  public fn Equals obj = (
    isStruct obj \
        and isProperty obj #CategoryName \
        and isProperty obj #ColorName \
        and isProperty obj #DisabledColor \
        and isProperty obj #HoverColor \
        and isProperty obj #ValueColor \
        and (
          if classOf obj.CategoryName == String \
              and classOf this.CategoryName == String then (
            stricmp obj.CategoryName this.CategoryName == 0
          )
          else (
            obj.CategoryName == this.CategoryName
          )
        ) \
        and (
          if classOf obj.ColorName == String \
              and classOf this.ColorName == String then (
            stricmp obj.ColorName this.ColorName == 0
          )
          else (
            obj.ColorName == this.ColorName
          )
        ) \
        and obj.DisabledColor == this.DisabledColor \
        and obj.HoverColor == this.HoverColor \
        and obj.ValueColor == this.ValueColor
  ),

  on Create do ()
)

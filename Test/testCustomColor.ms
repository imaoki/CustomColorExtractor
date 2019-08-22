/*! © 2015 imaoki | MIT License | https://github.com/imaoki */
struct TestStruct (
  public CurrentDir,
  public CurrentFile,
  public ParentDir,

  private actual,
  private expected,
  private testDef,
  private testObj,

  public fn Setup = (
    ok
  ),

  public fn SetupStruct = (
    this.testDef = ::unitTest.Import (this.ParentDir + @"\CustomColor.ms")
    -- this.testObj = this.testDef()

    ::unitTest.InvokeTest()
    ok
  ),

  public fn Teardown = (
    ok
  ),

  public fn TeardownStruct = (
    -- this.testObj.Dump()
    ok
  ),

  public fn Test01 = (
    this.expected = ::TestValue (
      this.testDef \
          CategoryName:"Appearance" \
          ColorName:"Button" \
          DisabledColor:(Color 255 0 0) \
          HoverColor:(Color 0 255 0) \
          ValueColor:(Color 0 0 255)
    )

    -- 大文字と小文字を区別しない
    this.actual = ::TestValue (
      this.testDef \
          CategoryName:"appearance" \
          ColorName:"button" \
          DisabledColor:(Color 255 0 0) \
          HoverColor:(Color 0 255 0) \
          ValueColor:(Color 0 0 255)
    )
    assert (this.actual.Equals this.expected == true)

    -- 未定義のパラメータ
    this.actual = ::TestValue (
      this.testDef \
          CategoryName:"Appearance" \
          ColorName:"Button" \
          ValueColor:(Color 0 0 255)
    )
    assert (this.actual.Equals this.expected == false)

    -- 異なるカラー値
    this.actual = ::TestValue (
      this.testDef \
          CategoryName:"Appearance" \
          ColorName:"Button" \
          DisabledColor:(Color 255 0 1) \
          HoverColor:(Color 0 255 0) \
          ValueColor:(Color 0 0 255)
    )
    assert (this.actual.Equals this.expected == false)

    ok
  ),

  on Create do (
    this.CurrentFile = ::unitTest.GetFullPath (getSourceFileName())
    this.CurrentDir = ::unitTest.GetDirectoryName this.CurrentFile
    this.ParentDir = ::unitTest.GetDirectoryName this.CurrentDir
  )
)

::unitTest.Run (::TestStruct())

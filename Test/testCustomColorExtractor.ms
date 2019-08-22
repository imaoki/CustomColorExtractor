/*! © 2019 imaoki | MIT License | https://github.com/imaoki */
struct TestStruct (
  public CurrentDir,
  public CurrentFile,
  public ParentDir,

  private actual,
  private expected,
  private testDef,
  private testObj,

  private customColorDef,

  private predefinesStringLogicalComparer,

  public fn Setup = (
    ok
  ),

  public fn SetupStruct = (
    this.customColorDef = ::unitTest.Import (this.ParentDir + @"\CustomColor.ms")
    this.predefinesStringLogicalComparer = this.isPredefineStringLogicalComparer()

    this.testDef = ::unitTest.Import (this.ParentDir + @"\CustomColorExtractor.ms")
    this.testObj = this.testDef()

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

  public fn Test01GetCategoryNames = (
    local names = #(
      "Appearance",
      "Trackbar",
      "Viewports",
      "ActiveShade",
      "Track View",
      "Manipulators",
      "Objects",
      "Material Editor",
      "Gizmos",
      "Geometry",
      "No Category",
      "Schematic View",
      "Snaps",
      "Scene Explorer",
      "Particle Flow",
      "Character",
      "Node Views",
      "Unwrap Colors",
      "UVW Map",
      "3D Painter",
      "Skin Colors",
      "HSDS Controls",
      "VertexPaint",
      "xView",
      "Particle Flow Tools"
    )
    if this.predefinesStringLogicalComparer then (
      qsort names ::stringLogicalComparer.Compare
    )
    else (
      sort names
    )

    this.actual = ::TestValue (this.testObj.GetCategoryNames())
    this.expected = ::TestValue names
    assert (this.actual.IsArray() == true)
    assert (this.actual.Equals this.expected == true)
    ok
  ),

  public fn Test02GetColor = (
    -- 失敗
    this.actual = ::TestValue (this.testObj.GetColor "Button" categoryName:"Unknown")
    this.expected = ::TestValue undefined
    assert (this.actual.Equals this.expected == true)

    -- 成功
    this.actual = ::TestValue (this.testObj.GetColor "Button" categoryName:"Appearance")
    this.expected = ::TestValue (
      this.customColorDef \
          CategoryName:"Appearance" \
          ColorName:"Button" \
          DisabledColor:(Color 89 89 89) \
          HoverColor:(Color 56 56 56) \
          ValueColor:(Color 100 100 100)
    )
    assert (this.actual.Equals this.expected == true)
    ok
  ),

  public fn Test03GetColorNames = (
    local names = #(
      "Trackbar Background",
      "Trackbar Selected Background",
      "Trackbar Text",
      "Trackbar Ticks",
      "Keys: Unknown",
      "Keys: Selected",
      "Trackbar Cursor",
      "Keys: Position",
      "Keys: Rotation",
      "Keys: Scale",
      "Keys: Transform",
      "Keys: Objects",
      "Keys: Materials",
      "Keys: Mixed",
      "Trackbar Cached Line",
      "Trackbar Cache Line"
    )
    if this.predefinesStringLogicalComparer then (
      qsort names ::stringLogicalComparer.Compare
    )
    else (
      sort names
    )

    this.actual = ::TestValue (this.testObj.GetColorNames categoryName:"Trackbar")
    this.expected = ::TestValue names
    assert (this.actual.IsArray() == true)
    assert (this.actual.Equals this.expected == true)
    ok
  ),

  -- public fn Test04Refresh = (
  --   ok
  -- ),

  private fn isPredefineStringLogicalComparer = (
    GlobalVars.IsGlobal "stringLogicalComparer" \
        and classOf ::stringLogicalComparer == DotNetObject \
        and isProperty ::stringLogicalComparer "Compare" \
        and classOf ::stringLogicalComparer.Compare == DotNetMethod
  ),

  on Create do (
    this.CurrentFile = ::unitTest.GetFullPath (getSourceFileName())
    this.CurrentDir = ::unitTest.GetDirectoryName this.CurrentFile
    this.ParentDir = ::unitTest.GetDirectoryName this.CurrentDir
  )
)

::unitTest.Run (::TestStruct())

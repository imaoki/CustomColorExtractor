/*! © 2020 imaoki | MIT License | https://github.com/imaoki */
/**
clrxファイルの`CustomColors`要素の内容を抽出する。
*/
struct CustomColorExtractor (
  /** @prop <DotNetObject:System.Xml.XmlDocument> */
  private document,
  /** @prop <String> */
  private file,

  /** @prop <StructDef:CustomColor> */
  private customColorDef,
  /** @prop <Array<Struct:CustomColor>> */
  private customColors = #(),

  /** @prop <DotNetClass:System.Text.RegularExpressions.Regex> */
  private regexClass = DotNetClass "System.Text.RegularExpressions.Regex",
  /** @prop <DotNetObject:System.Text.RegularExpressions.Regex> `#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})`に一致する正規表現オブジェクト。 */
  private hexColorRegex,

  /**
  現在の内部状態を出力する。
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @return <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%CustomColorExtractor\n" indent to:out
    format "%  file:@\"%\"\n" indent this.file to:out

    format "%  customColors: %\n" indent this.customColors.Count to:out
    for i = 1 to this.customColors.Count do (
      format "%    [%]:\n" indent i to:out
      this.customColors[i].Dump indent:(indent + "      ") out:out
    )
    ok
  ),

  /**
  カテゴリ名の配列を取得する。
  @return <Array<String>>
  */
  public fn GetCategoryNames = (
    local categoryNames = for customColor in this.customColors collect (
      customColor.CategoryName
    )
    categoryNames = makeUniqueArray categoryNames

    if this.isPredefineStringLogicalComparer() then (
      qsort categoryNames ::stringLogicalComparer.Compare
    )
    else (
      sort categoryNames
    )

    categoryNames
  ),

  /**
  カラー情報を取得する。
  @param colorName <String>
  @param categoryName: <String> カテゴリ名。
  指定した場合は指定したカテゴリ内から検索する。
  未指定の場合は最初に見つかったカラー情報を返す。
  @return <Struct:CustomColorStruct|UndefinedClass>
  @remark 大文字と小文字を区別しない。
  */
  public fn GetColor colorName categoryName: = (
    local result = undefined
    for customColor in this.customColors while result == undefined do (
      if stricmp customColor.ColorName colorName == 0 do (
        if classOf categoryName == String then (
          if stricmp customColor.CategoryName categoryName == 0 do (
            result = customColor
          )
        )
        else (
          result = customColor
        )
      )
    )
    result
  ),

  /**
  カラー名の配列を取得する。
  @param categoryName: <String>カテゴリ名。
  指定した場合は指定したカテゴリのカラー名のみ取得する。
  未指定の場合は全てのカラー名を取得する。
  @return <Array<String>>
  @remark 大文字と小文字を区別しない。
  */
  public fn GetColorNames categoryName: = (
    local colorNames = for customColor in this.customColors collect (
      local colorName = customColor.ColorName
      if classOf categoryName == String then (
        if stricmp customColor.CategoryName categoryName == 0 then (
          colorName
        )
        else (
          dontCollect
        )
      )
      else (
        colorName
      )
    )
    colorNames = makeUniqueArray colorNames

    if this.isPredefineStringLogicalComparer() then (
      qsort colorNames ::stringLogicalComparer.Compare
    )
    else (
      sort colorNames
    )

    colorNames
  ),

  /**
  clrxファイルを読み込んで内部状態に反映する。
  @return <OkClass>
  */
  public fn Refresh = (
    this.document.Load this.File

    local colorNodes = this.document.SelectNodes "//color"
    this.customColors = for i = 0 to colorNodes.Count - 1 collect (
      local customColor = this.customColorDef()
      local colorNode = colorNodes.ItemOf[i]
      for j = 0 to colorNode.Attributes.Count - 1 do (
        local attribute = colorNode.Attributes.ItemOf[j]
        local attrName = toLower attribute.LocalName
        local attrValue = toLower attribute.Value
        case attrName of (
          ("disabled"): customColor.DisabledColor = this.hexToColor attrValue
          ("hover"): customColor.HoverColor = this.hexToColor attrValue
          ("name"): customColor.ColorName = attribute.Value
          ("value"): customColor.ValueColor = this.hexToColor attrValue
          default: ()
        )
      )
      local categoryNode = colorNode.ParentNode
      for j = 0 to categoryNode.Attributes.Count - 1 \
          while customColor.CategoryName == "" do (
        local attribute = categoryNode.Attributes.ItemOf[j]
        local attrName = toLower attribute.LocalName
        if attrName == "name" do (
          customColor.CategoryName = attribute.Value
        )
      )
      customColor
    )

    -- this.Dump()
    ok
  ),

  /**
  16進数カラーコードを`Color`値に変換する。
  @param input <String>
  @return <Color>
  */
  private fn hexToColor input = (
    local result = Color 0 0 0
    local matches = this.hexColorRegex.Matches input
    if matches.Count == 1 and matches.Item[0].Groups.Count == 4 do (
      local groups = matches.Item[0].Groups
      result.R = Bit.HexAsInt groups.Item[1].Value
      result.G = Bit.HexAsInt groups.Item[2].Value
      result.B = Bit.HexAsInt groups.Item[3].Value
    )
    result
  ),

  /**
  `::stringLogicalComparer`が定義されているかどうかを判定する。
  @return <BooleanClass>
  */
  private fn isPredefineStringLogicalComparer = (
    GlobalVars.IsGlobal "stringLogicalComparer" \
        and classOf ::stringLogicalComparer == DotNetObject \
        and isProperty ::stringLogicalComparer "Compare" \
        and classOf ::stringLogicalComparer.Compare == DotNetMethod
  ),

  on Create do (
    this.document = DotNetObject "System.Xml.XmlDocument"
    this.file = ColorMan.GetFileName()
    this.customColorDef = fileIn "CustomColor.ms"

    local hexColorPattern = "#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})"
    this.hexColorRegex = DotNetObject this.regexClass hexColorPattern

    this.Refresh()
  )
)

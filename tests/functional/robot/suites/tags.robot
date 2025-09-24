*** Settings ***
Documentation   Tests create tag functionality

Resource    ../resources/variables.resource
Resource    ../resources/keywords/common.resource
Resource    ../resources/keywords/tags.resource
Library     Collections

*** Test Cases ***
Create Valid Tag Via API
    [Documentation]     Good Case. Successfully create a new tag via API.

    ${new_tag_label}=       Create Unique String    Tag_Label
    Set Global Variable     ${new_tag_label}
    ${new_tag_color}=       Create String Length    7

    ${resp}=        Create Tag Via API      ${new_tag_label}    ${new_tag_color}
    ${new_tag}=     Set Variable            ${resp.json()}     

    Set Global Variable     ${new_tag}

    Should Be Equal As Integers     ${resp.status_code}     201
    Dictionary Should Contain Key   ${new_tag}              id
    Should Be Equal                 ${new_tag["label"]}     ${new_tag_label}
    Should Be Equal                 ${new_tag["color"]}      ${new_tag_color}
    
    Wait For Tag By ID To Exist In DB    ${new_tag["id"]}
    Validate Tag In DB Via ID    ${new_tag["id"]}     ${new_tag_label}     ${new_tag_color}

Create Tag Without Label And Color Via API
    [Documentation]     Bad Case. Should NOT be able to create a new tag 
    ...                 via API if no label and color is specified 

    ${resp}=    Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...         Create Tag Via API    ${EMPTY}    ${EMPTY}

    Should Contain    ${resp}    400

Create Tag Without Label Via API
    [Documentation]     Bad Case. Should NOT be able to create a new tag
    ...                 via API if no label is specified 

    ${new_color}=   Create String Length            7
    ${resp}=        Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...             Create Tag Via API              ${EMPTY}    ${new_color}

    Should Contain    ${resp}    400

Create Tag Without Color Via API
    [Documentation]     Bad Case. Should NOT be able to create a new tag 
    ...                 via API if no color is specified 

    ${new_label}=   Create Unique String            Tag_Label
    ${resp}=        Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...             Create Tag Via API    ${new_label}    ${EMPTY}

    Should Contain    ${resp}    400

Create Tag With Existing Color Via API
    [Documentation]     Bad Case. Should NOT be able to create a new tag
    ...                 via API if specified label already exists. 

    ${new_color}=   Create String Length            7
    ${resp}=        Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...             Create Tag Via API              ${new_tag_label}      ${new_color}  

    Should Contain    ${resp}    400

Create Tag With Long Label Via API
    [Documentation]     Bad Case. Should NOT be able to create a new tag via
    ...                 API if label is greater than 128 characters.

    ${new_label_1}=     Create String Length            129
    ${new_color}=       Create String Length            7
    ${resp}=            Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...                 Create Tag Via API              ${new_label_1}    ${new_color}

    Should Contain     ${resp}  400

    ${new_label_2}=     Create String Length    128
    ${resp}=            Create Tag Via API      ${new_label_2}    ${new_color}

    Should Be Equal As Integers     ${resp.status_code}    201

Create Tag With Long Color Via API
    [Documentation]     Bad Case. Should NOT be able to create a new tag via
    ...                 API if color is greater than 7 characters.

    ${new_label}=       Create Unique String            Tag
    ${new_color_1}=     Create String Length            8
    ${resp}=            Run Keyword And Expect Error    HTTPError: 400 Client Error: Bad Request*
    ...                 Create Tag Via API              ${new_label}    ${new_color_1}

    Should Contain     ${resp}  400

    ${new_color_2}=     Create String Length    7
    ${resp}=            Create Tag Via API      ${new_label}    ${new_color_2}

    Should Be Equal As Integers     ${resp.status_code}    201

Create Valid Tag Via UI
    [Documentation]     Good Case. Create a tag using the UI

    # Sleep a bit to avoid having same label generated from the previous test
    # `Create Tag With Long Color Via API`
    Sleep    1s

    ${new_label}=   Create Unique String    Tag_Label

    Create Tag Via UI           ${new_label}

    Wait Until Page Contains    Tag created successfully    10s
    Wait Until Page Contains    ${new_label}                10s

    Wait For Tag By Label To Exist In DB    ${new_label}
    Validate Tag In DB Via Label            ${new_label}

Create Tag Without Label Via UI
    [Documentation]     Bad Case. Should NOT be able to create a new tag via
    ...                 UI without label.

    Create Tag Via UI       ${EMPTY}
    ${is_valid}=            Execute Javascript    
    ...                     return document.getElementById('id_label').checkValidity();
    Should Not Be True      ${is_valid}

Create Duplicate Tag Via UI
    [Documentation]     Bad Case. Should NOT be able to create a new tag via
    ...                 UI with existing name

    Create Tag Via UI               ${new_tag_label}
    Wait Until Page Contains        Tag with this Label already exists.    10s

*** Settings ***
Documentation   Keywords for Cabinet Test Suite
Library         RequestsLibrary
Library         SeleniumLibrary
Library         DatabaseLibrary
Resource        ../variables.resource
Resource        common.resource
Resource        metadata_type.resource
Resource        tags.resource

*** Keywords ***
Create Document Stub Via API
    [Documentation]     Create a document stub through POST request on API path 
    ...                 /api/v4/documents/. Only document type id is required to
    ...                 to create document via API.
    [Arguments]         ${document_type_id}     ${label}=

    ${body}=        Create Dictionary   document_type_id=${document_type_id}    label=${label}
    ${resp}=        POST On Session     api         /api/v4/documents/    json=${body}
    ...             headers=${HEADERS}

    RETURN      ${resp}

Add File To Document Stub Via API
    [Documentation]     Add a file to specified document through POST request on
    ...                 API path /api/v4/documents/<document_id>/files/.
    [Arguments]         ${document_id}      ${action_name}      ${filepath}=${FILE_PATH}    ${filename}=${FILENAME}

    ${auth}=        Create Dictionary   Authorization=Token ${AUTH_TOKEN}
    ${files}=       Create Dictionary   file_new=@${filepath} 
    ${body}=        Create Dictionary   action_name=${action_name}      filename=${filename}
    ${resp}=        POST On Session     api                 /api/v4/documents/${document_id}/files/
    ...             data=${body}        headers=${auth}     files=${files}

    RETURN      ${resp}

Add No File To Document Stub Via API
    [Documentation]     Add a file to specified document through POST request on
    ...                 API path /api/v4/documents/<document_id>/files/.
    [Arguments]         ${document_id}      ${action_name}

    ${auth}=        Create Dictionary   Authorization=Token ${AUTH_TOKEN}
    ${body}=        Create Dictionary   action_name=${action_name}
    ${resp}=        POST On Session     api                 /api/v4/documents/${document_id}/files/
    ...             data=${body}        headers=${auth}

    RETURN      ${resp}

Create Document Stub Via UI
    # [Documentation]     Create a document using the UI
    # [Arguments]         ${new_label}    
    #
    # Go To   ${BASE_URL}/documents/documents/create/
    #
    # Wait Until Element Is Visible   id=id_label     15s
    # Wait Until Element Is Visible   name=submit     15s
    #
    # Input Text      id=id_label             ${new_label}
    # Click Button    name=submit
    No Operation

Get Document Stub By ID
    [Documentation]     Get document using document ID via database query.
    [Arguments]         ${id}
    ${rows}=            Query   
    ...                 SELECT id,label,document_type_id FROM documents_document WHERE id = ${id}
    RETURN              ${rows}

Document Stub Should Exist In DB By ID
    [Documentation]         Checks that `Get Document Stub By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${id}
    ${rows}=                Get Document Stub By ID    ${id}
    Should Not Be Empty     ${rows}

Wait For Document Stub By ID To Exist In DB
    [Documentation]     Waits until given document exists in the database.
    [Arguments]         ${id}   ${timeout}=10s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Document Stub Should Exist In DB By ID   ${id}

Validate Document Stub In DB Via ID
    [Documentation]     Checks that the given label and document_type id matches 
    ...                 the details in the database.
    [Arguments]         ${id}   ${expected_label}

    ${rows}=                Get Document Stub By ID    ${id}
    Should Not Be Empty     ${rows}

    # row = [id, label, document_type_id]
    ${row}=                         Set Variable    ${rows}[0]
    Should Be Equal                 ${row[1]}       ${expected_label}
    Should Be Equal As Integers     ${row[2]}       1

Get Document Stub By Label
    [Documentation]     Get document using document ID via database query.
    [Arguments]         ${label}
    ${rows}=            Query   
    ...                 SELECT id,label,document_type_id FROM documents_document WHERE label = '${label}'
    RETURN              ${rows}

Document Stub Should Exist In DB By Label
    [Documentation]         Checks that `Get Document Stub By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${label}
    ${rows}=                Get Document Stub By Label    ${label}
    Should Not Be Empty     ${rows}

Wait For Document Stub By Label To Exist In DB
    [Documentation]     Waits until given document exists in the database.
    [Arguments]         ${label}   ${timeout}=10s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Document Stub Should Exist In DB By Label   ${label}

Validate Document Stub In DB Via Label
    [Documentation]     Checks that the given label and document_type_id matches 
    ...                 the details in the database.
    [Arguments]         ${label}

    ${rows}=    Get Document Stub By Label    ${label}
    Should Not Be Empty    ${rows}

    # row = [id, label, document_type_id]
    ${row}=                         Set Variable    ${rows}[0]
    Should Not Be Empty             ${row}
    Should Be Equal As Integers     ${row[2]}       1

Get File By ID
    [Documentation]     Get file using document ID via database query.
    [Arguments]         ${document_id}
    ${rows}=            Query   
    ...                 SELECT id,document_id,filename FROM documents_documentfile WHERE document_id = ${document_id}
    RETURN              ${rows}

File Should Exist In DB
    [Documentation]         Checks that `Get File By ID` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${id}
    ${rows}=                Get File By ID  ${id}
    Should Not Be Empty     ${rows}

Wait For File To Exist In DB
    [Documentation]     Waits until given document exists in the database.
    [Arguments]         ${fi1ename}     ${id}       ${timeout}=30s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             File Should Exist In DB     ${id}

Validate File Added To Document
    [Documentation]     Checks that the given filename matches the filename in
    ...                 the database.
    [Arguments]         ${filename}     ${id}

    ${rows}=                Get File By ID         ${id}
    Should Not Be Empty     ${rows}

    # row = [id, document_id, filename]
    ${row}=                 Set Variable    ${rows}[0]
    Should Not Be Empty     ${row}
    Should Be Equal         ${row[2]}       ${filename}

Add Metadata To Document Via API
    [Documentation]     Add specified metadata to specified document.
    [Arguments]         ${metadata_type_id}     ${id}

    ${body}=    Create Dictionary   metadata_type_id=${metadata_type_id}   value=Some Random Value
    ${resp}=    POST On Session     api         /api/v4/documents/${id}/metadata/    json=${body}
    ...         headers=${HEADERS}

    RETURN      ${resp}

Get Metadata Document By ID
    [Documentation]     Get id of metadata_documentmetadata using metadata type ID
    [Arguments]         ${metadata_type_id}
    ${rows}=            Query   
    ...                 SELECT id,document_id,metadata_type_id FROM metadata_documentmetadata WHERE metadata_type_id = ${metadata_type_id}
    RETURN              ${rows}

Metadata Document Should Exist In DB
    [Documentation]         Checks that `Get Metadata Document By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${id}
    ${rows}=                Get Metadata Document By ID  ${id}
    Should Not Be Empty     ${rows}

Wait For Metadata Document To Exist In DB
    [Documentation]     Waits until given document exists in the database.
    [Arguments]         ${id}       ${timeout}=30s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Metadata Document Should Exist In DB     ${id}

Validate Metadata Added To Document
    [Documentation]     Checks that the given metadata exists in the document in
    ...                 the database.
    [Arguments]         ${metadata_id}     ${documnet_id}

    ${rows}=                Get Metadata Document By ID     ${metadata_id}
    Should Not Be Empty     ${rows}

    ${matches}=    Evaluate    [r for r in ${rows} if r[1] == ${documnet_id}]
    Length Should Be    ${matches}    1

    # row = [id, document_id, metadata_id]
    ${row}=                 Set Variable    ${matches}[0]
    Should Not Be Empty     ${row}
    Should Be Equal         ${row[1]}       ${documnet_id}

Add Tag To Document Via API
    [Documentation]     Add specified tag to specified document.
    [Arguments]         ${tag_id}     ${id}

    ${body}=    Create Dictionary   tag=${tag_id}
    ${resp}=    POST On Session     api         /api/v4/documents/${id}/tags/attach/    json=${body}
    ...         headers=${HEADERS}

    RETURN      ${resp}

Get Tag Document By ID
    [Documentation]     Get id of tags_tag_documents using tag ID
    [Arguments]         ${tag_id}
    ${rows}=            Query   
    ...                 SELECT id,document_id,tag_id FROM tags_tag_documents WHERE tag_id = ${tag_id}
    RETURN              ${rows}

Tag Document Should Exist In DB
    [Documentation]         Checks that `Get Tag Document By Id` keyword does not return 
    ...                     an empty list [].
    [Arguments]             ${id}
    ${rows}=                Get Tag Document By ID  ${id}
    Should Not Be Empty     ${rows}

Wait For Tag Document To Exist In DB
    [Documentation]     Waits until given document exists in the database.
    [Arguments]         ${id}       ${timeout}=30s      ${interval}=1s

    Wait Until Keyword Succeeds     ${timeout}   ${interval}
    ...                             Tag Document Should Exist In DB     ${id}

Validate Tag Added To Document
    [Documentation]     Checks that the given tag exists in the document in
    ...                 the database.
    [Arguments]         ${tag_id}     ${documnet_id}

    ${rows}=                Get Tag Document By ID     ${tag_id}
    Should Not Be Empty     ${rows}

    ${matches}=    Evaluate    [r for r in ${rows} if r[1] == ${documnet_id}]
    Length Should Be    ${matches}    1

    # row = [id, document_id, tag_id]
    ${row}=                 Set Variable    ${matches}[0]
    Should Not Be Empty     ${row}
    Should Be Equal         ${row[1]}       ${documnet_id}

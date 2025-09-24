*** Settings ***
Documentation   Stores constant variables

*** Variables ***
${BASE_URL}     http://localhost:8081
${BROWSER}      Chrome
${USERNAME}     admin
${PASSWORD}     YCFERznVuj

${FILEPATH}     ${CURDIR}/../data/TestFile.pdf
${FILENAME}     TestFile.pdf

# postgre 
${DBMODULE}     psycopg2
${DBNAME}       mayan
${DBUSER}       mayan
${DBPASS}       mayandbpass
${DBHOST}       localhost
${DBPORT}       5432

# This is a sample Python script.

# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.
import streamlit as st
from datetime import datetime
import time
from botocore.exceptions import ClientError
import socket
import snowflake.connector
import ast
from PIL import Image


def main():
    time_trigger = int(st.secrets.timer_trigger)
    st.title('Color Legend')
    legend = st.columns(3)
    red = Image.open('Red_rectangle.jpeg')
    blue = Image.open('blue_rectangle.jpeg')
    orange = Image.open('orange flag.png')
    legend[0].image(red, caption='Down', width=64)
    legend[1].image(blue, caption='Source Up', width=64)
    legend[2].image(orange, caption='Target Up', width=64)
    st.title('Failover Status')

#    cols[0].image(blue, caption='Source pipenv shellActive', width=200)
#    cols[1].image(orange, caption='Target is Up', width=200)
    debug = st.expander("Debug Details", expanded=False)
         # Create a KV Client
    try:
        # to test locally the credentials if they expire https://github.com/Azure/azure-sdk-for-python/issues/16828
        sfpassword =  st.secrets.sfpassword
        sfuser =  st.secrets.sfuser
        sftestquery_raw =  st.secrets.sfhamonitor
        sftestquery = ast.literal_eval(sftestquery_raw)
        sfaccountpri =  st.secrets.sfaccountpri  # default demo06
        sfaccountsec =  st.secrets.sfaccountsec   # default demo28
        sfaccountlocatorprimary =  st.secrets.sfaccountlocatorprimary
        sfaccountlocatorsecondary =  st.secrets.sfaccountlocatorsecondary
        hostnamesfsuffex =  st.secrets.hostnamesfsuffex
        sfdb =  st.secrets.sfdb
        sfschema =  st.secrets.sfschema
        sleeptime = int( st.secrets.sleeptime )  # defatul 5 sec
        triesnum = int( st.secrets.triesnum )  # default 2
        # sfwarehouse =  st.secrets.sfwarehouse")
        failovergroup =  st.secrets.failovergroup
        sfclientredirectconnname =  st.secrets.sfclientredirectconnname
        # sfglobalaccountname =  st.secrets.sfglobalaccountname")
        portnumber = int( st.secrets.portnumber )
    except  ClientError as e:
        print(e)
        print("failed to get failover configurations from :"  + "  Azure KeyVault")
        debug.write(e)
        debug.write("failed to get failover configurations from :" +  "  Azure KeyVault")
    pri_is_promoted = True
    sec_is_promoted = False
    pri_is_active = True
    sec_is_active = False
    # testing connectivity of both Pri and Seconday  record the accounts connectivity and functionality status
    accountnames = st.columns(2)
    accountnames[0].subheader(sfaccountpri)
    accountnames[1].subheader(sfaccountsec)
    while True:
        cols = st.columns(2)
        pri_conn_is_up = test_connectivity(sfaccountpri + hostnamesfsuffex, portnumber, debug)
        sec_conn_is_up = test_connectivity(sfaccountsec + hostnamesfsuffex, portnumber, debug)
        # record the Snowflake accounts functionality status after running the test queries
        if pri_conn_is_up:
            print(sfaccountpri + " : https connectivity was successful trying the test query.........")
            debug.write(sfaccountpri + " : https connectivity was successful trying the test query.........")
            sf_account_status = retrieve_the_current_primary_account(sfaccountpri, sfaccountsec,sfaccountlocatorprimary, sfaccountlocatorsecondary,sfuser, sfpassword, debug)
            debug.write(sf_account_status)
            pri_is_functional = test_snowflake_ha(sfaccountpri, sfuser, sfpassword, sftestquery, triesnum, sleeptime, sfdb,sfschema, debug)
        else:
            pri_is_functional = False
            print(f"{sfaccountpri}: https connectivity was unsuccessful please verify your function that can communicate with Your Snowflake account or Make sure you privatelink setup is working as per Snowflake documentation https://docs.snowflake.com/en/user-guide/admin-security-privatelink.html  if your privatelink and your lmabda function connect to all your Snowflake account and still faillng  then contact Snowflake support")
            debug.write(sfaccountpri + " : https connectivity was unsuccessful" + " please verify your lambda fucntion that can communicate with Your Snowflake account" + " or Make sure you privatelink setup is working as per Snowflake documentation https://docs.snowflake.com/en/user-guide/admin-security-privatelink.html" +                          " if your privatelink and your lmabda function connect to all your Snowflake account and still faillng  then contact Snowflake support")
        if sec_conn_is_up:
            print(sfaccountsec + " : https connectivity was successful trying test query.........")
            debug.write(sfaccountsec + " : https connectivity was successful trying test query.........")
            sf_account_status = retrieve_the_current_primary_account(sfaccountpri, sfaccountsec,sfaccountlocatorprimary, sfaccountlocatorsecondary,sfuser, sfpassword, debug)
            debug.write(sf_account_status)
            sec_is_functional = test_snowflake_ha(sfaccountsec, sfuser, sfpassword, sftestquery, triesnum, sleeptime, sfdb,sfschema, debug)
        else:
            sec_is_functional = False
            print(sfaccountsec +" : https connectivity was unsuccessful" + "   please verify your lambda fucntion that can communicate with Your Snowflake account"+ "Make sure you privatelink setup is working as per Snowflake documentation https://docs.snowflake.com/en/user-guide/admin-security-privatelink.html" +" if your privatelink and your lmabda function connect to all your Snowflake account and still faillng  then contact Snowflake support")
            debug.write(sfaccountsec + " : https connectivity was unsuccessful" + "   please verify your lambda fucntion that can communicate with Your Snowflake account" + "Make sure you privatelink setup is working as per Snowflake documentation https://docs.snowflake.com/en/user-guide/admin-security-privatelink.html" + " if your privatelink and your lmabda function connect to all your Snowflake account and still faillng  then contact Snowflake support")
        if not pri_conn_is_up and not sec_conn_is_up:
            sec_is_functional = False
            pri_is_functional = False
            print("both accounts are not reachable over https please verify that your lambda function has proper connectivity: check routing table, nat gw, igw, security groups or " + "if anything blocks https connectivity to snowflake")
            debug.write("both accounts are not reachable over https please verify that your lambda function has proper connectivity: check routing table, nat gw, igw, security groups or " + "if anything blocks https connectivity to snowflake")

        # ============================================================================================================
        # ================= Analyze the account primary/secondary status, failover, fall back status =====================================
        if pri_is_functional and sec_is_functional and sf_account_status['pri_is_active']:
            print("Primary account " + sfaccountpri + " is functional")
            print("Secondary account " + sfaccountsec + " is functional as well but it is standby now")
            debug.write("Primary account " + sfaccountpri + " is functional")
            debug.write("Secondary account " + sfaccountsec + " is functional as well but it is standby now")
            cols[0].image(blue, caption='Source Up '+datetime.now().strftime("%H:%M:%S"), width=200)
            cols[1].image(orange, caption='Target Up '+datetime.now().strftime("%H:%M:%S"), width=200)

        if pri_is_functional and sec_is_functional and sf_account_status['sec_is_active']:
            print("Primary account " + sfaccountpri + " is functional")
            print("Secondary account " + sfaccountsec + " is functional and it is primary failover over has happened before.  You can revert back manually fallback ")
            debug.write("Primary account " + sfaccountpri + " is functional")
            debug.write("Secondary account " + sfaccountsec + " is functional and it is primary failover over has happened before.  You can revert back manually fallback ")
            cols[0].image(orange, caption='Target Up '+datetime.now().strftime("%H:%M:%S"), width=200)
            cols[1].image(blue, caption='Source Up '+datetime.now().strftime("%H:%M:%S"), width=200)

        if not pri_is_functional and not sec_is_functional:
            print("Critical Error : Primary account " + sfaccountpri + " is NOT functional")
            print("Critical Error : Secondary account " + sfaccountsec + " is NOT functional please verify")
            print("Critical Error :  Please verify that you can login to your Snowflake accounts using the provided credentials"
                " Verify that you have  warehouses created with auto resume on"
                "Verify that you have  DB and proper schema in your SF accounts"
                " if all that still failing  then contact Snowflake support")
            debug.write("Critical Error : Primary account " + sfaccountpri + " is NOT functional")
            debug.write("Critical Error : Secondary account " + sfaccountsec + " is NOT functional please verify")
            debug.write("Critical Error :  Please verify that you can login to your Snowflake accounts using the provided credentials"
                " Verify that you have  warehouses created with auto resume on"
                "Verify that you have  DB and proper schema in your SF accounts"
                " if all that still failing  then contact Snowflake support")
            cols[0].image(red, caption='Down check your settings '+datetime.now().strftime("%H:%M:%S"), width=200)
            cols[1].image(red, caption='Down check your settings'+datetime.now().strftime("%H:%M:%S"), width=200)

        if pri_is_functional and not sec_is_functional and sf_account_status['pri_is_active']:
            print("Primary account " + sfaccountpri + " :  is functional  but pay attention to the seconday account may be down not functional")
            print("Warning : Secondary account " + sfaccountsec + ":  is NOT functional please verify")
            debug.write("Primary account " + sfaccountpri + " :  is functional  but pay attention to the seconday account may be down not functional")
            debug.write("Warning : Secondary account " + sfaccountsec + ":  is NOT functional please verify")
            cols[0].image(blue, caption='Source Up '+datetime.now().strftime("%H:%M:%S"), width=200)
            cols[1].image(red, caption='Target Down '+datetime.now().strftime("%H:%M:%S"), width=200)

        if not pri_is_functional and sec_is_functional and sf_account_status['sec_is_active']:
            print("Warning : Primary account " + sfaccountpri + " :  is secondary now but is NOT functional please verify")
            print("Secondary account " + sfaccountsec + " :   is functional. However failover has happened, revert back is not turned on .. meanwhile make sure the primary is back online")
            debug.write("Warning : Primary account " + sfaccountpri + " :  is secondary now but is NOT functional please verify")
            debug.write("Secondary account " + sfaccountsec + " :   is functional. However failover has happened, revert back is not turned on .. meanwhile make sure the primary is back online")
            cols[0].image(red, caption='Target Down '+datetime.now().strftime("%H:%M:%S"), width=200)
            cols[1].image(blue, caption='Source Up '+datetime.now().strftime("%H:%M:%S"), width=200)

        if pri_is_functional and not sec_is_functional and sf_account_status['sec_is_active']:
            print("Critical Error : Primary account " + sfaccountpri + " :  is now functional")
            print(
                "Critical Error : Secondary account " + sfaccountsec + " :   Is now Snowflake Primary and is NOT functional."
                                                                       " However failover has happened before , but automatic revert back is not turned on ..you revert back manually")
            debug.write("Critical Error : Primary account " + sfaccountpri + " :  is now functional")
            debug.write(
                "Critical Error : Secondary account " + sfaccountsec + " :   Is now Snowflake Primary and is NOT functional."
                                                                       " However failover has happened before , but automatic revert back is not turned on ..you revert back manually")
            cols[0].image(orange, caption='Target Up '+datetime.now().strftime("%H:%M:%S"), width=200)
            cols[1].image(red, caption='Source Down Please Initiate Fallback '+datetime.now().strftime("%H:%M:%S"), width=200)

        if not pri_is_functional and sec_is_functional and sf_account_status['pri_is_active']:
            # primary function test failed
            print(
                "Warning : Primary account :" + sfaccountpri + " is NOT functional while the secondary account :" + sfaccountsec + " seems to be functional please initiate failover ........")
            debug.write(
                "Warning : Primary account :" + sfaccountpri + " is NOT functional while the secondary account :" + sfaccountsec + " seems to be functional please initiate failover ........")
            cols[0].image(red, caption='Source Down '+datetime.now().strftime("%H:%M:%S"), width=200)
            cols[1].image(orange, caption='Target Up Please Initiate Failover '+datetime.now().strftime("%H:%M:%S"), width=200)
        time.sleep(int(time_trigger))


# ====================================================================================
# ==============  Support functions  =================================================


def test_connectivity(host_name, portnumber, debug):
    threeway = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        # test connectivity
        threeway.settimeout(4)
        threeway.connect((host_name, portnumber))
        account_is_up = True
        metric = 1
        print("The TCP connection to  " + host_name + " was successful. testing next the cannary query")
        debug.write("The TCP connection to  " + host_name + " was successful. testing next the cannary query")
        debug.write(' (Health Check for resource ' + host_name + ')')
        return account_is_up
    except socket.error as e:
        metric = 0
        debug.write(' (Health Check for resource ' + host_name + ')')
        print("The TCP connection to  " + host_name + "failed Details: ", e)
        debug.write("The TCP connection to  " + host_name + "failed Details: ", e)
        account_is_up = False
        return account_is_up
    except:
        metric = 0
        debug.write(' (Health Check for resource ' + host_name + ')')
        print("The TCP connection to  " + host_name + "failed Details: ")
        debug.write("The TCP connection to  " + host_name + "failed Details: ")
        account_is_up = False
        return account_is_up


def retrieve_the_current_primary_account(sfaccountpri, sfaccountsec, sfaccountlocatorprimary, sfaccountlocatorsecondary,
                                         sfuser, sfpassword, debug):
    pri_is_active = False
    pri_is_promoted = False
    sec_is_active = False
    sec_is_promoted = False
    try:
        ctx = snowflake.connector.connect(
            user=sfuser,
            password=sfpassword,
            account=sfaccountpri,
            role="accountadmin"
        )
        cs = ctx.cursor()
        print("Trying..... to determine which account currently is primary using show connections")
        debug.write("Trying..... to determine which account currently is primary using show connections")
        cs.execute("show connections")
        raw = cs.fetchall()
        for r in raw:
            if r[6] == "true":
                if r[11] == sfaccountlocatorprimary:
                    pri_is_active = True
                    pri_is_promoted = True
                    sec_is_active = False
                    sec_is_promoted = False
                if r[11] == sfaccountlocatorsecondary:
                    pri_is_active = False
                    pri_is_promoted = False
                    sec_is_active = True
                    sec_is_promoted = True
        debug.write(
            f'pri_is_active : {pri_is_active} sec_is_active  : {sec_is_active}  sec_is_promoted  : {sec_is_promoted} pri_is_promoted  :   {pri_is_promoted}')
        print(
            f'pri_is_active : {pri_is_active} sec_is_active  : {sec_is_active}  sec_is_promoted  : {sec_is_promoted} pri_is_promoted  :   {pri_is_promoted}')
        # return {'pri_is_active': pri_is_active, 'sec_is_active': sec_is_active, 'sec_is_promoted': sec_is_promoted, 'pri_is_promoted':pri_is_promoted}
    except snowflake.connector.ProgrammingError as e:
        print(
            e + "   :" + "connecting the primary account failed Trying..... to determine which account currently is primary using show connections from secondary account")
        debug.write(
            e + "   :" + "connecting the primary account failed Trying..... to determine which account currently is primary using show connections from secondary account")
        try:
            ctx = snowflake.connector.connect(
                user=sfuser,
                password=sfpassword,
                account=sfaccountsec,
                role="accountadmin"
            )
            cs = ctx.cursor()
            print("Trying..... to determine which account currently is primary using show connections")
            debug.write("Trying..... to determine which account currently is primary using show connections")
            cs.execute("show connections")
            raw = cs.fetchall()
            for r in raw:
                if r[11] == sfaccountlocatorprimary:
                    pri_is_active = True
                    pri_is_promoted = True
                    sec_is_active = False
                    sec_is_promoted = False
                if r[11] == sfaccountlocatorsecondary:
                    pri_is_active = False
                    pri_is_promoted = False
                    sec_is_active = True
                    sec_is_promoted = True
            # return {'pri_is_active': pri_is_active, 'sec_is_active': sec_is_active, 'sec_is_promoted': sec_is_promoted,'pri_is_promoted': pri_is_promoted}
        except snowflake.connector.ProgrammingError as e:
            print(e + "   :" + "both accounts are inaccessible ")
            debug.write(e + "   :" + "both accounts are inaccessible ")
            # return {'pri_is_active': False, 'sec_is_active': False, 'sec_is_promoted': False, 'pri_is_promoted': False}
    debug.write(
        f'pri_is_active : {pri_is_active} sec_is_active  : {sec_is_active}  sec_is_promoted  : {sec_is_promoted} pri_is_promoted  :   {pri_is_promoted}')
    print(
        f'pri_is_active : {pri_is_active} sec_is_active  : {sec_is_active}  sec_is_promoted  : {sec_is_promoted} pri_is_promoted  :   {pri_is_promoted}')
    return {'pri_is_active': pri_is_active, 'sec_is_active': sec_is_active, 'sec_is_promoted': sec_is_promoted,
            'pri_is_promoted': pri_is_promoted}


def test_snowflake_ha(sfaccount_name, sfuser, sfpassword, query_text, triesnum, sleeptime, sfdb, sfschema, debug):
    i = 0
    while i < int(triesnum):
        try:
            ctx = snowflake.connector.connect(
                user=sfuser,
                password=sfpassword,
                account=sfaccount_name,
                database=sfdb,
                schema=sfschema
            )
            cs = ctx.cursor()
            print("Trying..... First warehouse " + query_text['test_wh_1'])
            debug.write("Trying..... First warehouse " + query_text['test_wh_1'])
            cs.execute(query_text['test_wh_1'])
            print("Snowflake Connection and " + query_text['test_wh_1'] + " was successful")
            print("Trying..... " + query_text['test_query_1'])
            debug.write("Snowflake Connection and " + query_text['test_wh_1'] + " was successful")
            debug.write("Trying..... " + query_text['test_query_1'])
            cs.execute(query_text['test_query_1'])
            print("Snowflake Connection and " + query_text['test_query_1'] + " was successful")
            debug.write("Snowflake Connection and " + query_text['test_query_1'] + " was successful")
            account_is_functional = True
            metric = 1
            print(f"Snowflake Connection and {query_text}  the canary query were successful")
            debug.write(f"Snowflake Connection and {query_text} the canary query were successful")
            debug.write(' (Health Check for resource ' + sfaccount_name + ')')
        except snowflake.connector.ProgrammingError as e:
            print(e)
            try:
                print("Trying..... Second warehouse because the first one failed" + query_text['test_wh_2'])
                debug.write("Trying..... Second warehouse because the first one failed" + query_text['test_wh_2'])
                cs.execute(query_text['test_wh_2'])
                print("Snowflake Connection and " + query_text['test_wh_2'] + " was successful")
                print("Trying..... " + query_text['test_query_2'])
                debug.write("Snowflake Connection and " + query_text['test_wh_2'] + " was successful")
                debug.write("Trying..... " + query_text['test_query_2'])
                cs.execute(query_text['test_query_2'])
                print("Snowflake Connection and " + query_text['test_query_2'] + " was successful")
                debug.write("Snowflake Connection and " + query_text['test_query_2'] + " was successful")
                account_is_functional = True
                metric = 1
                print(f"Snowflake Connection and {query_text}  the canary query were successful")
                debug.write(f"Snowflake Connection and {query_text}  the canary query were successful")
                debug.write(' (Health Check for resource ' + sfaccount_name + ')')
            except snowflake.connector.ProgrammingError as e:
                metric = 0
                account_is_functional = False
                print(e)
                debug.write(e)
                debug.write(' (Health Check for resource ' + sfaccount_name + ')')
                print("The Snowflake connections and the canary query was unsuccessful.")
                debug.write("The Snowflake connections and the canary query was unsuccessful.")
        except snowflake.connector.Error as e:
            print(e)
            debug.write(e)
            metric = 0
            account_is_functional = False
            debug.write(' (Health Check for resource ' + sfaccount_name + ')')
            print("The Snowflake connections and the canary query was unsuccessful.")
            debug.write("The Snowflake connections and the canary query was unsuccessful.")
        i = i + 1
        if i < int(triesnum):
            time.sleep(int(sleeptime))
        print("Try Numner :", i, type(i), "out of : ", triesnum)
        print("sleeptime :", sleeptime, type(sleeptime))
    debug.write(f" the {sfaccount_name} functional status afer canary query is : {account_is_functional}")
    return account_is_functional


def promote_account(sfaccount_name, sfuser, sfpassword, failovergroup, sfclientredirectconnname, debug):
    # building the query dict
    promote_query = {
        'account_conn_promote': 'ALTER CONNECTION ' + sfclientredirectconnname + ' PRIMARY;',
        'db_rep_promote': 'ALTER FAILOVER GROUP  IF EXISTS   ' + failovergroup + ' PRIMARY;'
    }
    account_is_promoted = False
    try:
        ctx = snowflake.connector.connect(
            user=sfuser,
            password=sfpassword,
            account=sfaccount_name,
        )
        cs = ctx.cursor()
        cs.execute('use role accountadmin')
        print("Attempting to Promote " + sfaccount_name + " connection to be primary for client redirect..... " +
              promote_query['account_conn_promote'])
        debug.write("Attempting to Promote " + sfaccount_name + " connection to be primary for client redirect..... " +
                     promote_query['account_conn_promote'])
        cs.execute(promote_query['account_conn_promote'])
        print(sfaccount_name + " is promoted to be primary for client redirect " + promote_query[
            'account_conn_promote'] + " was successful")
        print("Attempting to Promote Database" + failovergroup + " to be primary in account " + sfaccount_name + ".... " +
            promote_query['db_rep_promote'])
        debug.write(sfaccount_name + " is promoted to be primary for client redirect " + promote_query[
            'account_conn_promote'] + " was successful")
        debug.write("Attempting to Promote Database" + failovergroup + " to be primary in account " + sfaccount_name + ".... " +
            promote_query['db_rep_promote'])
        cs.execute(promote_query['db_rep_promote'])
        print(sfaccount_name + " is now primary for for " + failovergroup + " Database" + promote_query[
            'db_rep_promote'] + " was successful")
        debug.write(sfaccount_name + " is now primary for for " + failovergroup + " Database" + promote_query[
            'db_rep_promote'] + " was successful")
        account_is_promoted = True
        print("Snowflake account " + sfaccount_name + "is now primary for both replicated DB " + failovergroup + " and connection  :" + sfclientredirectconnname)
        debug.write("Snowflake account " + sfaccount_name + "is now primary for both replicated DB " + failovergroup + " and connection  :" + sfclientredirectconnname)
        print(' (Promoted ' + sfaccount_name + ' and ' + failovergroup + 'are both now primary)')
        debug.write(' (Promoted ' + sfaccount_name + ' and ' + failovergroup + 'are both now primary)')
        cs.close()
        # return account_is_promoted
    except snowflake.connector.ProgrammingError as e:
        account_is_promoted = False
        print(e)
        debug.write(e)
        debug.write(' (Failed to Promote ' + sfaccount_name + ' and ' + failovergroup + ')')
        cs.close()
        # return account_is_promoted
    except snowflake.connector.Error as e:
        print(e)
        debug.write(e)
        account_is_promoted = False
        debug.write(' (Failed to Promote ' + sfaccount_name + ' and ' + failovergroup + ')')
        print("Attempting to promote the connection and the account to primary was unsuccessful.")
        debug.write("Attempting to promote the connection and the account to primary was unsuccessful.")
        cs.close()
    return account_is_promoted

if __name__ == "__main__":
    main()

# Troubleshoot Cloud to Server Migrations

## Sysadmin user can't login

When you restore a Jira Cloud site backup to a standalone (self-hosted) server a sysadmin account should become
available for subsequent login and setup. Most importantly, you will need to login and setup an email server so existing
users can recover their passwords (credentials for all accounts other than the sysadmin account will have been disabled
following a restore).

Once the system has restarted, following a restore, you should be able to login with the following credentials:

| Account  | Password |
|:-------- |:---------|
| sysadmin | sysadmin |

If you find you can't login then you will need to make manual corrections at the database.

> The instructions in this guide assume Postgres is the underlying database.

<a name="step-1"></a>

## Step 1: Verify the current encryption method

Check if the encryption method has been set:

```sql
psql=> select attribute_value from cwd_directory_attribute
    where attribute_name like '%encryption_method%';
  attribute_value
--------------------
 atlassian-security
(1 row)
```

If the query returns 0 rows, proceed to [Step 2](#step-2). Otherwise, skip to [Step 3](#step-3).

<a name="step-2"></a>

## Step 2: Add an encryption method if needed

Determine the directory id of the JIRA Internal Directory:

```sql
psql=> select id from cwd_directory where directory_name ='JIRA Internal Directory';
 id
----
  1
(1 row)
```

Add a binding between the internal directory and its security method:

```sql
psql=> insert into cwd_directory_attribute (directory_id, attribute_value, attribute_name)
    values (<your_directory_id>,'atlassian-security','user_encryption_method');
```

In the above example, `<your_directory_id>` is the `id` returned by the previous query.

Proceed to [Step 4](#step-4)

<a name="step-3"></a>

## Step 3: Update the encryption method if needed

If the `attribute-value` returned in [Step 1](#step-1) is not set to _atlassian-security_, update the encryption
method:

```sql
psql=> update cwd_directory_attribute set attribute_value = 'atlassian-security'
    where attribute_name = 'user_encryption_method';
```

Proceed to [Step 4](#step-4)

<a name="step-4"></a>

## Step 4: Restart Jira

After making changes as described above you will need to restart the Jira container.

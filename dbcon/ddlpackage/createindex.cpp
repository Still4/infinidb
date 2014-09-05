/* Copyright (C) 2014 InfiniDB, Inc.

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; version 2 of
   the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA. */

/***********************************************************************
*   $Id: createindex.cpp 9210 2013-01-21 14:10:42Z rdempsey $
*
*
***********************************************************************/

#include "ddlpkg.h"

namespace ddlpackage {
	using namespace std;
	
	CreateIndexStatement::CreateIndexStatement():
		fIndexName(NULL),
		fTableName(NULL),
		fColumnNames(),
		fUnique(false)
	{
	}
	
	CreateIndexStatement::CreateIndexStatement(QualifiedName *indexName, QualifiedName *tableName,
			ColumnNameList *columnNames, bool unique) :
		fIndexName(indexName),
		fTableName(tableName),
		fColumnNames(*columnNames),
		fUnique(unique)
	{
		delete columnNames;
	}

	CreateIndexStatement::~CreateIndexStatement()
	{
		delete fIndexName;
		delete fTableName;
	}

	std::ostream& CreateIndexStatement::put(std::ostream& os) const 
	{
		os << "Create Index: " << *fIndexName << " on " << *fTableName
		   << fColumnNames << endl;
		return os;
	}
	
}

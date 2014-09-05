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

/****************************************************************************
* $Id: func_right.cpp 3715 2013-04-18 16:33:13Z bpaul $
*
*
****************************************************************************/

#include <string>
using namespace std;

#include "functor_str.h"
#include "functioncolumn.h"
#include "utils_utf8.h"
using namespace execplan;

#include "rowgroup.h"
using namespace rowgroup;

#include "joblisttypes.h"
using namespace joblist;

namespace funcexp
{

CalpontSystemCatalog::ColType Func_right::operationType(FunctionParm& fp, CalpontSystemCatalog::ColType& resultType)
{
	// operation type is not used by this functor
	return fp[0]->data()->resultType();
}


std::string Func_right::getStrVal(rowgroup::Row& row,
						FunctionParm& fp,
						bool& isNull,
						execplan::CalpontSystemCatalog::ColType&)
{
	string tstr = fp[0]->data()->getStrVal(row, isNull);
	if (isNull)
		return "";

	int64_t pos = fp[1]->data()->getIntVal(row, isNull);
	if (isNull)
		return "";

	if (pos == -1)  // pos == 0
		return "";

	size_t strwclen = utf8::idb_mbstowcs(0, tstr.c_str(), 0) + 1;
	//wchar_t wcbuf[strwclen];
	wchar_t* wcbuf = (wchar_t*)alloca(strwclen * sizeof(wchar_t));
	strwclen = utf8::idb_mbstowcs(wcbuf, tstr.c_str(), strwclen);
	wstring str(wcbuf, strwclen);

	if ( (unsigned) pos >= strwclen )
		pos = strwclen;
	
	wstring out = str.substr(strwclen-pos,strwclen);
	size_t strmblen = utf8::idb_wcstombs(0, out.c_str(), 0) + 1;
	//char outbuf[strmblen];
	char* outbuf = (char*)alloca(strmblen * sizeof(char));
	strmblen = utf8::idb_wcstombs(outbuf, out.c_str(), strmblen);
	return string(outbuf, strmblen);
}							


} // namespace funcexp
// vim:ts=4 sw=4:


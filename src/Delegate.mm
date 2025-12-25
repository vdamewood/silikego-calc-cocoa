/* Delegate.mm: Delegate for Cocoa
 * Copyright 2012-2025 Vincent Damewood
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <memory>
#import <Cocoa/Cocoa.h>

#include <SilikegoCore/InfixParser.h>
#include <SilikegoCore/SyntaxTree.h>
#include <SilikegoCore/FunctionCaller.h>
#include <SilikegoCore/StringSource.h>

#import "Delegate.h"

@implementation SilikegoGuiDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.caller = new Silikego::FunctionCaller();
	Silikego::InstallOperators(*self.caller);
	Silikego::InstallFunctions(*self.caller);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	delete self.caller;
}

- (IBAction) Calculate:(id)sender
{
	Silikego::SyntaxTreeNode Ast = Silikego::ParseInfix(
		std::unique_ptr<Silikego::DataSource>(new Silikego::StringSource(
			[[self.input stringValue] UTF8String])));
	Silikego::Value Result = Ast.evaluate(*self.caller);

	switch (Result.status())
	{
	case Silikego::ValueStatus::Integer:
		[self.output setIntegerValue: Result.toInteger()];
		break;
	case Silikego::ValueStatus::Real:
		[self.output setDoubleValue: Result.toReal()];
		break;
	case Silikego::ValueStatus::Error:
		switch (Result.toError())
		{
		case Silikego::Error::Memory:
			[self.output setStringValue: @"Out of memory"];
			break;
		case Silikego::Error::Syntax:
			[self.output setStringValue: @"Syntax error"];
			break;
		case Silikego::Error::ZeroDivision:
			[self.output setStringValue: @"Division by zero"];
			break;
		case Silikego::Error::FunctionName:
			[self.output setStringValue: @"Function not found"];
			break;
		case Silikego::Error::FunctionArguments:
			[self.output setStringValue: @"Bad argument count"];
			break;
		case Silikego::Error::Domain:
			[self.output setStringValue: @"Domain error"];
			break;
		case Silikego::Error::Range:
			[self.output setStringValue: @"Range error"];
			break;
		default:
			[self.output setStringValue: @"Unexpected error"];
			break;
		}
	}
}
@end

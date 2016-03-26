.//========================================================================
.//
.//File:      $RCSfile: create_readonly_view_test.arc,v $
.//Version:   $Revision: 1.11 $
.//Modified:  $Date: 2013/01/10 23:15:17 $
.//
.//(c) Copyright 2004-2014 by Mentor Graphics Corp. All rights reserved.
.//
.//========================================================================
.// Licensed under the Apache License, Version 2.0 (the "License"); you may not 
.// use this file except in compliance with the License.  You may obtain a copy 
.// of the License at
.//
.//       http://www.apache.org/licenses/LICENSE-2.0
.//
.// Unless required by applicable law or agreed to in writing, software 
.// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT 
.// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   See the 
.// License for the specific language governing permissions and limitations under
.// the License.
.//========================================================================
.//
.invoke arc_env = GET_ENV_VAR( "PTC_MC_ARC_DIR" )
.assign mc_archetypes = arc_env.result
.if ( mc_archetypes == "" )
  .print "\nERROR: Environment variable PTC_MC_ARC_DIR not set."
  .exit 100
.end if
.//
.include "${mc_archetypes}/arch_utils.inc"
.//
.assign path = "org/xtuml/bp/ui/properties/test"
.assign class_name = "PropertiesViewReadOnlyTest"
//======================================================================
//
// File: ${path}/${class_name}.java
//
// WARNING:      Do not edit this generated file
// Generated by: ${info.arch_file_name}
// Version:      $$Revision: 1.11 $$
//
// (c) Copyright 2004-2014 by Mentor Graphics Corp.  All rights reserved.
//
//======================================================================
//
// This class is responsible for determing the dependency between
// classes for displaying property changes.
//
package org.xtuml.bp.ui.properties.test;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.viewers.CellEditor;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.views.properties.IPropertyDescriptor;
import org.junit.Before;
import org.junit.Test;
import org.xtuml.bp.core.*;
import org.xtuml.bp.test.common.BaseTest;
import org.xtuml.bp.core.common.ClassQueryInterface_c;
import org.xtuml.bp.core.common.PersistableModelComponent;
import org.xtuml.bp.ui.properties.*;
import org.xtuml.bp.test.*;
import org.xtuml.bp.test.TestUtil.Result1;

public class ${class_name} extends BaseTest
{
  public ${class_name}(String name) {
  	super(null, name);
  }	
    static private boolean firstTime = true;
	@Before
	public void setUp() throws Exception {
        if ( firstTime ) {
        PersistableModelComponent domain_pmc = ensureAvailableAndLoaded("testProp", false, false);
        setResourceToReadonly(domain_pmc);
        firstTime = false;
			}
		while (PlatformUI.getWorkbench().getDisplay().readAndDispatch());
	}
.select many node_set from instances of T_TNS
.for each node in node_set
  .// special case: the S_EEDI instance is never populated
  .// we do not honor read-only for an S_SYS
  .if (( node.Key_Lett != "S_EEDI" ) and ( node.Key_Lett  != "S_SYS" ))
    .select any meta_model_obj from instances of O_OBJ where (selected.Key_Lett == node.Key_Lett)
    .invoke formatted_name = get_class_name(meta_model_obj)
    .invoke gia = get_instance_accessor(meta_model_obj)
    @Test
	public void test$r{meta_model_obj.Name}_$r{node.CategoryName}Properties() throws Exception
    {
    .// special case: only interested in the domain testProp
    .if(node.Key_Lett == "S_DOM")
    	Domain_c inst = Domain_c.DomainInstance(modelRoot, new ClassQueryInterface_c() {
		
			public boolean evaluate(Object candidate) {
				if(((Domain_c)candidate).getName().equals("testProp")) {
					return true;
				}
				return false;
			}
			
		});
    .else
        ${formatted_name.body} inst = ${formatted_name.body}.${gia.body}(modelRoot);
    .end if
        $r{node.CategoryName}${meta_model_obj.Key_Lett}PropertySource ps = new $r{node.CategoryName}${meta_model_obj.Key_Lett}PropertySource(inst);
        IPropertyDescriptor [] pd_set = ps.getPropertyDescriptors();
        for(int i = 0; i < pd_set.length; i++) {
			String pkg = pd_set[i].getClass().getPackage().getName();
			String className = pd_set[i].getClass().getName().replaceFirst(pkg + ".",
					"");
			if ((!className.equals("DescriptionPropertyDescriptor"))
					&& (!className.equals("ActivityPropertyDescriptor"))) {
				CellEditor editor = pd_set[i].createPropertyEditor(new Shell());
				assertNull(editor);
			}
        }
    }
  .end if .// ( node.Key_Lett != "S_EEDI" )
.end for
}
.emit to file "src/${path}/${class_name}.java"
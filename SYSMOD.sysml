library package SYSMOD {
    doc
    /* Definition of SYSMOD Concepts for SysML v2
     *
     * Version v5.1 
     *
     * Licensed under the Apache License, Version 2.0 (the "License");
     * you may not use this file except in compliance with the License.
     * You may obtain a copy of the License at
     *
     * http://www.apache.org/licenses/LICENSE-2.0
     *
     * Unless required by applicable law or agreed to in writing, software
     * distributed under the License is distributed on an "AS IS" BASIS,
     * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     * See the License for the specific language governing permissions and
     * limitations under the License.
     *
     * Copyright 2026, MBSE4U
     */

    //
    // SYSMOD Project which links all the main artifacts together within a shared context.
    //
    occurrence def Project {
        doc
        /* The Project provides a context for the engineering artifacts used for this specific project and sets cross relationships. */

        occurrence subProjects : Project [*];

        part projectOwner :> projectStakeholders {
            doc
            /* The Project Owner is a special Stakeholder who is in charge of the Project. */
            attribute :>> risk default LevelKind::critical;
            attribute :>> effort default LevelKind::low;
            attribute :>> categories default StakeholderCategoryKind::requirementOwner;
        }
        part brownfieldContext : SystemContext {
            doc
            /* The Brownfield Context includes the system, its subcomponents, and actors that are already identified at the start of the Project. These constraints limit the set of possible solutions. */
        }
        part projectStakeholders : ExtendedStakeholder [0..*] {
            doc
            /* Stakeholders are individuals and organizations that have an interest in the system. They have needs and are potential sources of system requirements. */
        }
        concern problemStatement : ExtendedConcern {
            doc
            /* The Problem Statement is an elevator pitch that describes the problem the system of interest is intended to solve. It is based on the Brownfield system. The problem statement does not specify a solution. The project owner is the stakeholder of the problem statement. */
            subject brownfieldSystem :> brownfieldContext.soiImpl;
            stakeholder projectOwner :> Project::projectOwner;
            attribute :>> priority = LevelKind::critical;
        }
        concern stakeholderNeeds {
            doc
            /* The Stakeholder Needs is the root element for stakeholder needs which will be translated into system requirements. The needs are based on the brownfield system and frames the problem statement. */
            subject brownfieldSystem :> brownfieldContext.soiImpl;
            frame problemStatement;
        }
        part systemIdeaContext :> brownfieldContext {
            doc
            /* The system idea context contains the system idea and additional actors, if necessary. It specializes the brownfield system context. */
            part <soi> systemIdeaSystem :>> brownfieldContext::soi;
            part <soiImpl> systemIdeaSystemImpl :>> brownfieldContext::soiImpl :> soi {
                doc
                /* The system idea is the answer to the problem statement. It is a rough, elevator-pitch-style outline of the system designed to solve the problem. The system idea specializes the brownfield system. */
                satisfy Project::problemStatement;
            }
        }
        part specificationContext :> systemIdeaContext {
            doc
            /* The specification context includes the actors and the system, along with specific subcomponents, which are defined during the requirements analysis. The specification context is also the owner of the system use cases. The context specializes the system idea. */
            part <soi> specificationSystem :>> systemIdeaContext::soi;
            part <soiImpl> specificationSystemImpl :>> systemIdeaContext::soiImpl :> soi;
        }
        requirement systemRequirementSpecification {
            doc
            /* The System Requirement Specification is the root element for system requirements. They frame the stakeholder needs. */
            subject specificationSystem :> specificationContext.soi;
            frame stakeholderNeeds;
        }
        part solutionContext :> specificationContext {
            doc
            /* The Solution Context specializes the specification context and is the base context for the solution context. */
            part <soi> solutionSystem :>> specificationContext::soi;
            part <soiImpl> solutionSystemImpl :>> specificationContext::soiImpl :> soi {
                doc
                /* The solution system specializes the specification system and is the base system for the solution. It satisfies the system requirements. */
                satisfy systemRequirementSpecification;
            }
        }
        part functionalContext :> solutionContext [0..1] {
            doc
            /* The Functional Context is optional and specializes the solution context and provides the context for a functional architecture, for example, developed with the FAS method. */
            part functionalSystem {
                doc
                /* The Functional System is the root element of the functional architecture. It is part of the context in addition to the inherited solution system which may contain non-functional parts but is a reference for the functional architecture, such as owner of the functions. */
            }
        }
        part logicalContext :> solutionContext [0..1] {
            doc
            /* The Logical Context is optional and specializes the solution context and provides the context for a logical architecture. */
        }
        part productContext :> solutionContext {
            doc
            /* The Product Context specializes the solution context and provides the context for a product architecture. */
        }
        allocation functional2logical [0..1] allocate functionalContext to logicalContext;
        allocation logical2product [0..1] allocate logicalContext to productContext;
    }
    abstract occurrence projects : Project [*];

    //
    // SYSMOD System Context
    //
    part def SystemContext {
        doc
        /* The SYSMOD System Context includes all system actors, the system of interest, 
         * the relationships between the actors and the system, as well as the use cases.
         */
        part actors [1..*] {
            doc
            /* The actors of the system of interest, i.e., all external entities which interact with system including humans, external systems, and environmental effects. */
            port actorPort : ActorPort {
                doc
                /* Dedicated port of an actor to exchange items with the system. */
            }
        }
        part <soi> systemOfInterest {
            doc
            /* Black box system of interest. */
            port systemPorts : SystemPort [*];
        }
        part <soiImpl> systemOfInterestImplementation :> soi {
            doc
            /* White box system of interest. */
        }
        interface act2sys : ActorSystemInterface [1..*]
            connect actors.actorPort to soi.systemPorts {
            doc
            /* Set of all actor/system interfaces. */
        }
        use case useCases [0..*] {
            doc
            /* Set of all system use cases. */
            subject soi :> SystemContext::soi;
        }
    }
    abstract part systemContexts : SystemContext [*];

    interface def ActorSystemInterface {
        doc
        /* Common interface definition for the link between actors and the system of interest. */
        end [1..*] port actorPort : ActorPort;
        end [1] port systemPort : SystemPort;
    }
    port def ActorPort {
        doc
        /* Base port definition for actor ports. */
    }
    port def SystemPort {
        doc
        /* Base port definition for system ports. */
    }

    //
    // SYSMOD Stakeholder and Requirement Concepts
    //
    part def ExtendedStakeholder {
        doc
        /* SYSMOD-specific definition of a stakeholder concept */
        attribute risk : LevelKind default LevelKind::none {
            doc
            /* What is the risk of failure if I ignore this stakeholder? */
        }
        attribute effort : LevelKind default LevelKind::none {
            doc
            /* How much effort is involved in identifying this stakeholder's concerns and requirements? */
        }
        derived attribute priority : ScalarValues::Real = risk * effort {
            doc
            /* Priority is the product of risk and effort. */
        }
        attribute contact : ScalarValues::String [0..1] {
            doc
            /* Contact information of the stakeholder. */
        }
        attribute categories : StakeholderCategoryKind [*] {
            doc
            /* Stakeholder kinds */
        }
    }
    abstract part stakeholders : ExtendedStakeholder [*];

    enum def StakeholderCategoryKind {
        doc
        /* Different kinds of stakeholders. */
        expert;
        requirementOwner;
        user;
        other;
    }

    concern def ExtendedConcern {
        /* Base element for concerns. */
        attribute priority : LevelKind default LevelKind::none;
    }
    abstract concern extendedConcerns : ExtendedConcern [*];

    requirement def ExtendedRequirement :> ExtendedConcern {
        doc
        /* The extended requirement adds further features to the requirement model element. 
         * Typically, you would define your own set of features and not use the SYSMOD set only.
         */
        attribute obligation : ObligationKind default ObligationKind::none;
        attribute stability : StabilityKind default StabilityKind::none;
        attribute motivation : ScalarValues::String;
    }
    abstract requirement extendedRequirements : ExtendedRequirement [*];

    enum def ObligationKind {
        doc
        /* Enumeration for different kinds of obligations. */
        none;
        mandatory;
        optional;
    }
    enum def StabilityKind {
        doc
        /* Enumeration for stability kinds. */
        none;
        unstable;
        stable;
    }

    //
    // Common Concepts
    //
    enum def LevelKind :> ScalarValues::Real {
        doc
        /* Common enumeration of levels with real values, for example, for priority calculations. */
        none = 0.0;
        low = 0.25;
        medium = 0.5;
        high = 0.75;
        critical = 1.0;
    }

    //
    // AI
    //
    metadata def AI {
        attribute name : ScalarValues::String;
        attribute create_prompt : ScalarValues::String;
        attribute create_questions : ScalarValues::String [*];
        attribute validation_prompt : ScalarValues::String;
    }

    occurrence def AIProject :> Project {
        @AI {
            create_prompt =
                "1. Create the SysML v2 textual notation for the project definition using the SYSMOD-defined keyword: '#project occurrence def PROJECTNAME {}'
                2. Use the create_prompt of the AI metadata of the projectOwner to create the project owner of the project.
                3. If not given by the user, use the questions to get the name of the project and the location where the project should be added.";
            create_questions = (
                "What is the name of the project?", "Where should I add the project definition?",
            );
            validation_prompt =
                "Validate the project definition against the SYSMOD Project concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. The project is defined as an occurrence definition annotated with the #project keyword or specializing Project.
                2. A projectOwner part usage is present and subsets projectStakeholders.
                3. A brownfieldContext part usage is present and typed by a SystemContext specialization.
                4. A problemStatement concern usage is present.
                5. A stakeholderNeeds concern usage is present and frames the problemStatement.
                6. A systemIdeaContext part usage is present and specializes brownfieldContext.
                7. A specificationContext part usage is present and specializes systemIdeaContext.
                8. A systemRequirementSpecification requirement usage is present and frames stakeholderNeeds.
                9. A solutionContext part usage is present and specializes specificationContext.
                10. A productContext part usage is present and specializes solutionContext.
                11. The cross-artifact traceability chain is intact: problemStatement <- stakeholderNeeds <- systemRequirementSpecification, and satisfy relationships exist at the system idea and solution levels.
                12. If functionalContext or logicalContext are present, the corresponding functional2logical and logical2product allocations are defined.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata projectOwnerAI : AI about projectOwner {
            create_prompt =
                "1. If the user has provided a projectOwner, use it. If not, ask the user for the projectOwner using appropriate questions from the questions field.
                2. Create a concise projectOwner description.
                3. Create the SysML v2 textual notation for the projectOwner.
                4. If the user asks to insert the projectOwner into the SysML model, find the project and the projectOwner within the project. If no project exists, create one and insert the projectOwner into the project redefining the inherited projectOwner part usage. If the projectOwner already exists, update it.";
            create_questions = (
                "Who is the project owner?", "Who is responsible for the project?",
            );
            validation_prompt =
                "Validate the projectOwner against the SYSMOD Project Owner concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. Exactly one projectOwner part usage is present in the project, redefining the inherited projectOwner.
                2. The projectOwner subsets projectStakeholders and is typed by an ExtendedStakeholder specialization.
                3. The risk attribute is set to LevelKind::critical (the project owner always has critical risk).
                4. The effort attribute is set to LevelKind::low (the project owner is typically easy to reach).
                5. The categories attribute includes StakeholderCategoryKind::requirementOwner.
                6. The projectOwner is referenced as the stakeholder of the problemStatement.
                7. A meaningful name or doc comment identifies who the project owner is in the context of this project.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata brownfieldContextAI : AI about brownfieldContext {
            create_prompt =
                "1. Analyze the provided scenario and identify the brownfield system: the existing system, its relevant subcomponents, and all external actors (humans, external systems, environmental effects) that already interact with it before the project starts.
                2. Create a part definition for the brownfield system of interest specializing SystemContext.
                3. For each identified actor, add a part usage subsetting the inherited actors part.
                4. For the system of interest, redefine the inherited soi and soiImpl parts with appropriately named and typed part definitions.
                5. Ensure the brownfield context reflects constraints and givens only — it must not include solution elements.
                6. Create the SysML v2 textual notation for the brownfieldContext.
                7. If the user asks to insert the brownfieldContext into the SysML model, find the project and redefine the inherited brownfieldContext part usage. If the project does not exist, create one first.";
            create_questions = (
                "What is the name of the existing system (system of interest)?",
                "Which external actors (users, operators, external systems, environments) interact with the existing system?",
                "Are there any known subcomponents or subsystems of the existing system that are relevant?",
            );
            validation_prompt =
                "Validate the brownfieldContext against the SYSMOD Brownfield Architecture concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. The brownfieldContext part usage is present in the project and typed by a SystemContext specialization.
                2. At least one actor part usage subsetting actors is present, representing an external entity that interacts with the existing system.
                3. The soi part is redefined with a named part definition representing the existing system of interest.
                4. The soiImpl part is redefined and specializes soi, representing the white-box view of the existing system.
                5. Actor-system interfaces (act2sys) connect actor ports to system ports.
                6. The brownfield context contains only elements that exist before the project starts — no solution-specific parts, new system ideas, or future-state components.
                7. Each actor has a meaningful name and, ideally, a doc comment describing its role.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata problemStatementAI : AI about problemStatement {
            create_prompt =
                "1. Follow the structure between engineering artifacts given by the SYSMOD library.
                2. Analyze the provided scenario. If it is forward engineering, identify the problem statement from the given scenario. If it is reverse engineering, identify the problem statement by identifying the problem that is solved by the given system.
                3. Create a concise elevator-pitch style problem statement text (typically 150-250 words).
                4. Follow this format: 'How can we...'
                5. Ensure the problem statement text is based on the brownfieldContext. If the brownfieldContext is not available, create one that is implied by the problem statement text using the AI metadata about the brownfieldContext.
                6. Ensure that the problem statement does not jump to the solution and describe it in advance.
                7. Ensure that the stakeholder projectOwner is set by subsetting the corresponding part usage in the project, if given. If it is not available, use the create_prompt of the AI metadata about the projectOwner to create one.
                8. If it is reverse engineering, create a satisfy relationship between the given system and the problem statement.
                9. Create the SysML v2 textual notation for the problemStatement.
                10. If the user asks to insert the problemStatement into the SysML model, find the project and the problemStatement within the project. If no project exists, create one and insert the problemStatement into the project redefining the inherited problemStatement concern usage. If the problemStatement already exists, update it.";
            create_questions = (
                "What is the core problem the system should solve?",
                "What are the main deficiencies or pain points of the existing (brownfield) system?",
            );
            validation_prompt =
                "Validate the problemStatement against the SYSMOD Problem Statement concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. The problemStatement concern usage is present in the project, redefining the inherited problemStatement.
                2. The subject references the brownfieldContext soiImpl (the existing system is the subject of the problem).
                3. The projectOwner is set as the stakeholder of the problemStatement.
                4. The priority attribute is set to LevelKind::critical.
                5. A doc comment is present containing the problem statement text.
                6. The problem statement text starts with 'How can we...' or an equivalent problem-framing phrase.
                7. The problem statement text describes the problem, not a solution — check for premature solution language (e.g., 'we will build', 'the new system shall', named technologies or architectures).
                8. The problem statement text references the brownfield system and its deficiencies.
                9. The problem statement text is concise (typically 150-250 words).
                10. If it is reverse engineering, a satisfy relationship exists between the existing system and the problemStatement.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata projectStakeholdersAI : AI about projectStakeholders {
            create_prompt =
                "1. Analyze the brownfieldContext and the problemStatement and identify all relevant stakeholders (individuals or organizations with an interest in the system).
                2. For each stakeholder, create a part definition specializing ExtendedStakeholder.
                3. Assess and set the risk (what is the risk of failure if this stakeholder is ignored?), effort (how much effort is needed to identify their concerns?), and one or more stakeholder categories (user, requirementOwner, expert, other) for each stakeholder.
                4. Add each stakeholder as a named part usage subsetting projectStakeholders inside the project, typed by the corresponding stakeholder definition.
                5. Create the SysML v2 textual notation for all stakeholder definitions and their usages within the project.
                6. If the user asks to insert the stakeholders into the SysML model, find the project and add or update the stakeholder part usages.";
            create_questions = (
                "Who are the primary users of the system?",
                "Which organizations or roles own or define the requirements?",
                "Are there regulatory bodies, standards authorities, or other external parties with an interest in the system?",
            );
            validation_prompt =
                "Validate the projectStakeholders against the SYSMOD Stakeholders concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. At least one stakeholder part usage (beyond the projectOwner) subsets projectStakeholders.
                2. Each stakeholder part usage is typed by a part definition specializing ExtendedStakeholder.
                3. Each stakeholder definition has the risk attribute set to a non-default LevelKind value (i.e., not LevelKind::none).
                4. Each stakeholder definition has the effort attribute set to a non-default LevelKind value (i.e., not LevelKind::none).
                5. Each stakeholder definition has at least one category assigned from StakeholderCategoryKind.
                6. The set of stakeholders covers all actors present in the brownfieldContext — every actor should map to at least one stakeholder.
                7. At least one stakeholder with category requirementOwner is present (beyond the projectOwner).
                8. Each stakeholder has a doc comment or name that clearly identifies its role.
                9. No two stakeholders have identical risk, effort, and category values without a distinguishing doc comment explaining the distinction.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata stakeholderNeedsAI : AI about stakeholderNeeds {
            create_prompt =
                "1. Analyze the projectStakeholders and the problemStatement and derive the high-level needs of each stakeholder.
                2. For each stakeholder need, create a concern usage subsetting stakeholderNeeds, framed by the problemStatement and referencing the brownfieldContext as its subject.
                3. Ensure each need is expressed from the stakeholder's perspective and describes what they need the system to do or be, not how.
                4. Do not express needs as solution-specific requirements; keep them at the stakeholder intent level.
                5. Create the SysML v2 textual notation for the stakeholderNeeds.
                6. If the user asks to insert the stakeholderNeeds into the SysML model, find the project and redefine the inherited stakeholderNeeds concern usage. If the project does not exist, create one first.";
            create_questions = (
                "What does each stakeholder group need the system to do or be?",
                "Are there any known constraints or non-functional needs (safety, cost, compliance) expressed by stakeholders?",
            );
            validation_prompt =
                "Validate the stakeholderNeeds against the SYSMOD Stakeholder Needs concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. The stakeholderNeeds concern usage is present in the project, redefining the inherited stakeholderNeeds.
                2. The stakeholderNeeds frames the problemStatement.
                3. The subject references the brownfieldContext soiImpl.
                4. At least one stakeholder need is defined as a nested concern usage.
                5. Each stakeholder need is traceable to at least one stakeholder from projectStakeholders (via stakeholder reference or doc comment attribution).
                6. Each need is expressed at the stakeholder intent level — check for premature solution or design language (e.g., specific technologies, implementation details, design choices).
                7. The set of stakeholder needs covers all projectStakeholders — no stakeholder group should be left without at least one associated need.
                8. Each need has a doc comment or name that is understandable without reading the full model.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata systemIdeaContextAI : AI about systemIdeaContext {
            create_prompt =
                "1. Based on the problemStatement, develop a high-level system idea: an elevator-pitch-style outline of the new or changed system that solves the stated problem.
                2. Specialize the brownfieldContext by redefining the soi and soiImpl parts with a named system idea definition. The systemIdeaSystemImpl must include a satisfy relationship to the problemStatement.
                3. Add any additional actors that are introduced by the system idea and are not already present in the brownfieldContext.
                4. Keep the system idea at a conceptual level — no detailed architecture or design decisions.
                5. Create the SysML v2 textual notation for the systemIdeaContext.
                6. If the user asks to insert the systemIdeaContext into the SysML model, find the project and redefine the inherited systemIdeaContext part usage. If the project does not exist, create one first.";
            create_questions = (
                "What is the high-level concept or approach for the new or changed system?",
                "Are there any new actors introduced by the system idea that do not exist in the brownfield?",
            );
            validation_prompt =
                "Validate the systemIdeaContext against the SYSMOD System Idea concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. The systemIdeaContext part usage is present in the project and specializes brownfieldContext.
                2. The soi part is redefined with a named system idea definition that specializes the brownfield soi.
                3. The soiImpl part is redefined and specializes the system idea soi.
                4. The soiImpl contains a satisfy relationship to the problemStatement.
                5. All actors from the brownfieldContext are inherited or explicitly redefined — no brownfield actor should silently disappear.
                6. Any new actors introduced by the system idea are added as additional actor part usages.
                7. The system idea stays at a conceptual level — check for premature architecture or design detail (e.g., specific components, protocols, or technologies named in the soiImpl structure).
                8. A doc comment on the soiImpl describes the system idea in elevator-pitch style.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata specificationContextAI : AI about specificationContext {
            create_prompt =
                "1. Specialize the systemIdeaContext for requirements analysis by redefining the soi and soiImpl parts with specification-level system definitions.
                2. Identify and add any actors or subcomponents that become visible during requirements analysis (e.g., specific interfaces, subsystems defined at the black-box level).
                3. Add system use cases to the specificationContext that describe how actors interact with the system of interest at the specification level.
                4. Ensure the specificationContext owns the use cases and that each use case references the specificationSystem as its subject.
                5. Create the SysML v2 textual notation for the specificationContext including actor parts and use case usages.
                6. If the user asks to insert the specificationContext into the SysML model, find the project and redefine the inherited specificationContext part usage.";
            create_questions = (
                "Which use cases describe how actors interact with the system?",
                "Are there additional actors or subcomponents that become visible at the specification level?",
            );
            validation_prompt =
                "Validate the specificationContext against the SYSMOD Specification Context concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. The specificationContext part usage is present in the project and specializes systemIdeaContext.
                2. The soi part is redefined with a named specification system definition that specializes the system idea soi.
                3. The soiImpl part is redefined and specializes the specification soi.
                4. At least one use case usage is present in the specificationContext, referencing the specificationSystem as its subject.
                5. Each use case has at least one actor involved (include or extend relationships, or actor references in the use case subject/stakeholder).
                6. Each use case has a meaningful name and doc comment describing the interaction goal.
                7. All actors from the systemIdeaContext are inherited or redefined — no actor should silently disappear.
                8. The specificationContext does not contain solution architecture elements — it should remain a black-box view of the system.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata systemRequirementSpecificationAI : AI about systemRequirementSpecification {
            create_prompt =
                "1. Derive system requirements from the stakeholderNeeds, framed by the stakeholderNeeds and referencing the specificationSystem as subject.
                2. For each requirement, create a requirement usage or definition specializing ExtendedRequirement. Set obligation (mandatory/optional), stability (stable/unstable), and a brief motivation.
                3. Ensure each requirement is verifiable, unambiguous, and solution-neutral where possible.
                4. Group requirements logically (e.g., functional, performance, safety, interface) using nested requirement usages if appropriate.
                5. Create the SysML v2 textual notation for the systemRequirementSpecification.
                6. If the user asks to insert the systemRequirementSpecification into the SysML model, find the project and redefine the inherited systemRequirementSpecification requirement usage.";
            create_questions = (
                "What are the key functional requirements of the system?",
                "Are there non-functional requirements (performance, safety, reliability, compliance)?",
                "Which requirements are mandatory and which are optional?",
            );
            validation_prompt =
                "Validate the systemRequirementSpecification against the SYSMOD System Requirements concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. The systemRequirementSpecification requirement usage is present in the project, framing the stakeholderNeeds.
                2. The subject references the specificationContext soi (the specification system is the subject of the requirements).
                3. At least one system requirement is defined as a nested requirement usage or definition.
                4. Each requirement specializes ExtendedRequirement and has the obligation attribute set (not ObligationKind::none).
                5. Each requirement has the stability attribute set (not StabilityKind::none).
                6. Each requirement has a non-empty motivation attribute explaining why the requirement exists.
                7. Each requirement is traceable to at least one stakeholder need (via frame or derive relationships, or doc comment reference).
                8. Each requirement text is verifiable — check for vague qualifiers without measurable criteria (e.g., 'fast', 'easy', 'reliable' without a threshold).
                9. Each requirement is solution-neutral — check for implementation-specific language (named technologies, specific designs) that constrain the solution unnecessarily.
                10. The set of requirements covers all defined use cases — every use case should be reflected in at least one functional requirement.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata solutionContextAI : AI about solutionContext {
            create_prompt =
                "1. Specialize the specificationContext for the solution by redefining the soi and soiImpl parts with solution-level system definitions.
                2. The solutionSystemImpl must include a satisfy relationship to the systemRequirementSpecification.
                3. The solutionContext is the base for functional, logical, and product architectures — keep it at the integration level and avoid duplicating architecture details that belong in those sub-contexts.
                4. Create the SysML v2 textual notation for the solutionContext.
                5. If the user asks to insert the solutionContext into the SysML model, find the project and redefine the inherited solutionContext part usage.";
            create_questions = (
                "What is the name of the solution system?",
                "Are there any top-level solution elements already known at this stage?",
            );
            validation_prompt =
                "Validate the solutionContext against the SYSMOD Solution Context concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. The solutionContext part usage is present in the project and specializes specificationContext.
                2. The soi part is redefined with a named solution system definition that specializes the specification soi.
                3. The soiImpl part is redefined and specializes the solution soi.
                4. The soiImpl contains a satisfy relationship to the systemRequirementSpecification.
                5. The solutionContext does not duplicate architecture details that belong in functionalContext, logicalContext, or productContext.
                6. All actors from the specificationContext are inherited or redefined — no actor should silently disappear.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata functionalContextAI : AI about functionalContext {
            create_prompt =
                "1. If a functional architecture is required, specialize the solutionContext by redefining the soi and soiImpl parts for the functional level.
                2. Add a functionalSystem part as the root of the functional architecture (e.g., developed with the FAS method). This is separate from the inherited solution system and represents the functional decomposition.
                3. Define the top-level functions as action usages or part usages within the functionalSystem.
                4. If allocations to the logical architecture are known, note them; formal allocations are expressed via the functional2logical allocation in the project.
                5. Create the SysML v2 textual notation for the functionalContext.
                6. If the user asks to insert the functionalContext into the SysML model, find the project and redefine the inherited functionalContext part usage (note: multiplicity is [0..1]).";
            create_questions = (
                "Is a functional architecture required for this project?",
                "What are the top-level functions the system must perform?",
                "Should the functional architecture follow the FAS method or another approach?",
            );
            validation_prompt =
                "Validate the functionalContext against the SYSMOD Functional Architecture concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. If present, the functionalContext part usage specializes solutionContext and has multiplicity [0..1].
                2. A functionalSystem part is present as the root of the functional decomposition, separate from the inherited solution system.
                3. At least one top-level function is defined as an action usage or part usage within the functionalSystem.
                4. Each top-level function is traceable to at least one system requirement (via satisfy, refine, or doc comment reference).
                5. Functions are technology-independent — check for implementation-specific naming or structure that belongs in the logical or product architecture.
                6. If a logicalContext is present in the project, a functional2logical allocation is defined connecting the functionalContext to the logicalContext.
                7. The functionalSystem does not duplicate parts from the inherited solution system — it represents the functional view only.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata logicalContextAI : AI about logicalContext {
            create_prompt =
                "1. If a logical architecture is required, specialize the solutionContext by redefining the soi and soiImpl parts for the logical level.
                2. Define logical components as part usages within the logical system, representing technology-independent building blocks that realize the functional architecture.
                3. If allocations from the functional architecture are known, note them; formal allocations are expressed via the functional2logical allocation in the project.
                4. If allocations to the product architecture are known, note them; formal allocations are expressed via the logical2product allocation in the project.
                5. Create the SysML v2 textual notation for the logicalContext.
                6. If the user asks to insert the logicalContext into the SysML model, find the project and redefine the inherited logicalContext part usage (note: multiplicity is [0..1]).";
            create_questions = (
                "Is a logical architecture required for this project?",
                "What are the key logical components or subsystems?",
                "Are there technology-independent partitioning principles to apply (e.g., separation of concerns, layers)?",
            );
            validation_prompt =
                "Validate the logicalContext against the SYSMOD Logical Architecture concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. If present, the logicalContext part usage specializes solutionContext and has multiplicity [0..1].
                2. At least one logical component is defined as a part usage within the logical system.
                3. Logical components are technology-independent — check for product-specific naming, vendor names, physical form factors, or deployment-specific details that belong in the productContext.
                4. Each logical component is traceable to at least one function from the functionalContext (if present) via allocation or doc comment.
                5. If a functionalContext is present in the project, a functional2logical allocation is defined connecting functionalContext to logicalContext.
                6. If a productContext is present in the project, a logical2product allocation is defined connecting logicalContext to productContext.
                7. Logical component interfaces are defined where components interact, using port and interface definitions.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata productContextAI : AI about productContext {
            create_prompt =
                "1. Specialize the solutionContext for the product architecture by redefining the soi and soiImpl parts with concrete product-level definitions.
                2. Define product components as part usages within the product system, representing physical or deployable building blocks (hardware, software components, assemblies).
                3. If allocations from the logical architecture are known, note them; formal allocations are expressed via the logical2product allocation in the project.
                4. Include interfaces between product components where relevant.
                5. Create the SysML v2 textual notation for the productContext.
                6. If the user asks to insert the productContext into the SysML model, find the project and redefine the inherited productContext part usage.";
            create_questions = (
                "What are the main physical or deployable components of the system?",
                "Are there hardware/software splits or deployment boundaries to model?",
                "Which product components are derived from the logical architecture?",
            );
            validation_prompt =
                "Validate the productContext against the SYSMOD Product Architecture concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. The productContext part usage is present in the project and specializes solutionContext.
                2. At least one product component is defined as a part usage within the product system.
                3. Product components represent concrete, physical or deployable building blocks — check that logical or functional abstractions have been resolved to specific technologies, hardware types, or software components.
                4. Each product component is traceable to at least one logical component from the logicalContext (if present) via the logical2product allocation or doc comment.
                5. If a logicalContext is present in the project, a logical2product allocation is defined connecting logicalContext to productContext.
                6. Interfaces between product components are defined where components interact physically or through APIs.
                7. All system requirements are satisfied — verify that a satisfy relationship chain exists from the product architecture back to the systemRequirementSpecification (directly or via solutionContext).
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }

        metadata subProjectsAI : AI about subProjects {
            create_prompt =
                "1. If the project is decomposed into sub-projects, create occurrence definitions specializing Project (or AIProject) for each sub-project.
                2. Add each sub-project as an occurrence usage subsetting subProjects within the parent project.
                3. Ensure each sub-project has its own projectOwner, brownfieldContext, and problemStatement as appropriate.
                4. Cross-reference shared artifacts (e.g., shared stakeholders or requirements) by subsetting or referencing the parent project's elements.
                5. Create the SysML v2 textual notation for all sub-project definitions and their usages.
                6. If the user asks to insert sub-projects into the SysML model, find the parent project and add the sub-project occurrence usages.";
            create_questions = (
                "Should the project be decomposed into sub-projects?",
                "What are the names and scopes of the sub-projects?",
                "Do the sub-projects share stakeholders or requirements with the parent project?",
            );
            validation_prompt =
                "Validate the subProjects against the SYSMOD sub-project decomposition concept and report findings grouped as errors, warnings, and suggestions.
                Check:
                1. Each sub-project occurrence usage subsets the inherited subProjects and is typed by an occurrence definition specializing Project or AIProject.
                2. Each sub-project has at least a projectOwner and a brownfieldContext defined.
                3. Each sub-project has a problemStatement that is consistent with and narrower in scope than the parent project's problemStatement.
                4. Shared stakeholders between parent and sub-projects are referenced by subsetting the parent project's stakeholder part usages rather than duplicated as independent definitions.
                5. There are no overlapping scopes between sibling sub-projects — each sub-project addresses a distinct part of the parent problem.
                6. Each sub-project has a meaningful name and doc comment describing its scope and relationship to the parent project.
                Report each finding with the element name, the violated SYSMOD rule, and a concrete suggestion for correction.";
        }
    }

    //
    // Semantic Metadata
    //
    metadata def <project> ProjectMetadata :> Metaobjects::SemanticMetadata {
        :>> baseType = projects meta SysML::Type;
        :> annotatedElement : SysML::OccurrenceDefinition;
        :> annotatedElement : SysML::OccurrenceUsage;
    }
    metadata def <systemContext> SystemContextMetadata :> Metaobjects::SemanticMetadata {
        :>> baseType = systemContexts meta SysML::Type;
        :> annotatedElement : SysML::PartDefinition;
        :> annotatedElement : SysML::PartUsage;
    }
    metadata def <extendedStakeholder> StakeholderMetadata :> Metaobjects::SemanticMetadata {
        :>> baseType = stakeholders meta SysML::Type;
        :> annotatedElement : SysML::PartDefinition;
        :> annotatedElement : SysML::PartUsage;
    }
    metadata def <extendedConcern> ExtendedConcernMetadata :> Metaobjects::SemanticMetadata {
        :>> baseType = extendedConcerns meta SysML::Type;
        :> annotatedElement : SysML::ConcernDefinition;
        :> annotatedElement : SysML::ConcernUsage;
    }
    metadata def <extendedRequirement> ExtendedRequirementMetadata
        :> Metaobjects::SemanticMetadata {
        :>> baseType = extendedRequirements meta SysML::Type;
        :> annotatedElement : SysML::RequirementDefinition;
        :> annotatedElement : SysML::RequirementUsage;
    }
}

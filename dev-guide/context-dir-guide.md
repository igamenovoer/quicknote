# Context Directory Specification

This specification defines a standardized context directory structure for AI-assisted software development projects.

## Overview

The `context/` directory provides an organized workspace for AI coding assistants, enabling effective collaboration between human developers and AI systems. This structure maintains project knowledge, facilitates continuity across sessions, and provides reference materials for consistent development.

## Directory Structure Specification

```
context/
├── design/         # API and technical design documentation
├── plans/          # Implementation roadmaps and project planning
├── hints/          # Programming guides and development tutorials
├── summaries/      # Project knowledge base and experience repository
├── tasks/          # Human-defined task requests and specifications
├── logs/           # Development history and session continuity
├── refcode/        # Reference implementations and example code
├── tools/          # Custom development utilities and scripts
└── README.md       # Context directory overview and usage guide
```

## Subdirectory Specifications

### design/
**Purpose**: Store technical design documents and API specifications before implementation begins.

**Required Content Types**:
- API interface specifications and endpoint definitions
- System architecture diagrams and component relationships
- Technical decision documentation with rationales
- Data models and schema definitions
- Protocol specifications and integration patterns
- Security and performance requirement documentation

**Usage Requirements**:
- Create design documents before major implementation work
- Update designs when significant system changes occur
- Include rationale for technical decisions and trade-offs
- Document constraints, limitations, and future extensibility

### plans/
**Purpose**: Contain implementation roadmaps, project planning, and development coordination.

**Required Content Types**:
- Feature development plans with task breakdowns
- Sprint planning and milestone definitions
- Resource allocation and timeline estimates
- Risk assessment and mitigation strategies
- Release planning and versioning schedules
- Team coordination and workflow processes

**Usage Requirements**:
- Create plans before starting development cycles
- Break down complex features into manageable tasks
- Define success criteria and completion milestones
- Update plans as requirements and scope evolve

### hints/
**Purpose**: Provide programming tutorials, development guides, and best practice documentation.

**Required Content Types**:
- Technology-specific programming tutorials
- Development best practices and coding standards
- Common problem solutions and troubleshooting guides
- Tool usage instructions and workflow tips
- Framework-specific patterns and implementations
- Performance optimization techniques

**Usage Requirements**:
- Document recurring solutions for common problems
- Provide quick reference materials for development decisions
- Include code examples and practical demonstrations
- Maintain currency with evolving technologies and practices

### summaries/
**Purpose**: Maintain project experience repository and knowledge base.

**Required Content Types**:
- Lessons learned from development challenges
- Architecture evolution and design decision history
- Performance optimization discoveries and results
- Integration patterns and successful solutions
- Project retrospectives and improvement insights
- Technology evaluation summaries

**Usage Requirements**:
- Document significant learning experiences
- Capture architectural decisions and their outcomes
- Record successful problem-solving approaches
- Maintain institutional knowledge across team changes

### tasks/
**Purpose**: Coordinate specific development requests between humans and AI assistants.

**Required Content Types**:
- Clearly defined development task specifications
- Feature requirements with acceptance criteria
- Bug reports with reproduction steps
- Enhancement requests with business justification
- Research tasks with expected deliverables
- Maintenance and refactoring assignments

**Usage Requirements**:
- Provide clear, actionable task definitions
- Include acceptance criteria and success metrics
- Specify priority levels and deadlines
- Link to related issues or documentation

### logs/
**Purpose**: Maintain development history and session continuity for AI assistants.

**Required Content Types**:
- AI assistant session logs and conversation summaries
- Decision-making processes and outcomes documentation
- Debugging sessions with solution paths
- Project evolution timeline and major milestones
- Context preservation for multi-session projects
- Learning progression and capability development

**Usage Requirements**:
- Record significant development sessions and outcomes
- Document decision-making rationale for future reference
- Maintain continuity information for AI assistant context
- Track project evolution and learning progression

### refcode/
**Purpose**: Store reference implementations and example code from external sources.

**Required Content Types**:
- Example implementations from similar projects
- Library usage patterns and integration examples
- Best practice code demonstrations
- External repository references and git submodules
- Code snippets for common operations
- Framework-specific implementation patterns

**Usage Requirements**:
- Include clear attribution for external code sources
- Document relevance to current project needs
- Maintain licensing compliance for referenced code
- Update references when better examples become available
- Use subdirectories for different technologies or frameworks as needed
- Include git submodules for complete external repositories when appropriate

### tools/
**Purpose**: House custom development utilities and project-specific automation scripts.

**Required Content Types**:
- Code generation and analysis utilities
- Development workflow automation scripts
- Project-specific build and deployment tools
- Data processing and transformation utilities
- Testing and quality assurance helpers
- Documentation generation tools

**Usage Requirements**:
- Create tools that solve recurring development problems
- Document tool purpose, usage, and dependencies
- Maintain tools as project requirements evolve
- Share useful tools across similar projects
- Organize by functionality as needed
- Include usage documentation for each tool

## Implementation Requirements

### Mandatory Files

Each context directory MUST include:
1. **README.md** - Overview of the context directory structure and usage guidelines
2. **{subdirectory}/README.md** - Purpose documentation for each subdirectory explaining what it is for and what content it contains

### Content Standards

All documentation MUST follow these standards:
- Use Markdown format for consistency and readability
- Include clear purpose statements and usage instructions
- Provide examples where applicable
- Keep content current with project evolution
- Update README.md files to reflect actual content as directories are populated

### Access Patterns

AI assistants SHOULD:
1. Check relevant subdirectories when starting new tasks
2. Reference existing solutions before creating new implementations
3. Add new learnings and discoveries to appropriate locations
4. Update logs and summaries to maintain project continuity
5. Use the context directory to understand project history and patterns

### Maintenance Requirements

Project teams MUST:
1. Regularly review and update context directory content
2. Remove outdated or irrelevant information
3. Ensure new team members understand the context directory structure
4. Integrate context directory usage into development workflows
5. Maintain clear documentation for all custom tools and utilities

## Integration with Development Workflow

### Project Initialization
1. Create context directory structure with all specified subdirectories
2. Add README.md files to each subdirectory explaining its purpose
3. Include context directory in project documentation and onboarding materials

### Development Process
1. Consult relevant context subdirectories before starting new work
2. Document design decisions and technical choices in design/
3. Create implementation plans in plans/ for complex features
4. Record development sessions and outcomes in logs/
5. Add reusable solutions and patterns to hints/ and summaries/

### AI Assistant Integration
1. Provide context directory overview to AI assistants at project start
2. Direct AI assistants to check relevant subdirectories for existing solutions
3. Encourage AI assistants to contribute learnings back to the context directory
4. Use context directory to maintain continuity across AI assistant sessions

## Benefits and Outcomes

This specification provides:
- **Consistency**: Standardized structure across projects and teams
- **Continuity**: Preserved knowledge and context across development sessions
- **Efficiency**: Reduced duplication through shared knowledge and solutions
- **Quality**: Better decision-making through documented experience and best practices
- **Collaboration**: Enhanced human-AI collaboration through organized information sharing

## Version and Evolution

This specification should be versioned and updated as development practices evolve. Projects implementing this structure should:
- Track which version of the specification they follow
- Migrate to newer versions when beneficial
- Contribute improvements back to the specification
- Adapt the structure to project-specific needs while maintaining core principles

## Compliance and Adoption

Projects claiming compliance with this specification MUST:
- Implement all mandatory subdirectories and README.md files
- Follow the documented content standards
- Maintain the directory structure according to usage requirements
- Provide training or documentation for team members on context directory usage

This specification serves as a foundation for effective AI-assisted development workflows and can be adapted to specific project needs while maintaining consistency and interoperability across projects.
export interface ProjectTag {
  tagName: string
}

export interface ProjectItem {
  id: number
  name: string
  icon: ResourceStr
  describeInfo: string | null
  tags: ProjectTag[]
}

export class ProjectItemModel implements ProjectItem {
  id: number
  name: string
  icon: ResourceStr
  describeInfo: string | null
  tags: ProjectTag[]

  constructor(model: ProjectItem) {
    this.id = model.id
    this.name = model.name
    this.icon = model.icon
    this.describeInfo = model.describeInfo
    this.tags = model.tags
  }
}


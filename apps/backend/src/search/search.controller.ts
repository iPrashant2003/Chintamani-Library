import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { SearchService } from './search.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('search')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('search')
export class SearchController {
  constructor(private readonly searchService: SearchService) {}

  @Get()
  search(@Query('q') q: string, @Query('branchId') branchId: string) {
    if (!q || !branchId) return { members: [], seats: [], lockers: [], query: q };
    return this.searchService.search(q, branchId);
  }
}
